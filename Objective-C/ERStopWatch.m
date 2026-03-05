//
//  ERStopWatch.m
//
//  Created by Zhang Zhicheng on 12-8-27.

#import "ERStopWatch.h"
#import <mach/mach_time.h>

@interface ERStopWatchModel : NSObject
@property (nonatomic, assign) UInt64 startTick;
@property (nonatomic, assign) double_t seconds;
@property (nonatomic, assign) UInt64 offset;
@property (nonatomic, assign) ERStopWatchState state;
@end

@implementation ERStopWatchModel
@end

@implementation ERStopWatch

static NSMutableDictionary<NSString *, ERStopWatchModel *> *watches;
static NSLock *watchLock;

+ (void)initialize
{
    if (self != ERStopWatch.class) {
        return;
    }

    watches = [NSMutableDictionary dictionary];
    watchLock = [[NSLock alloc] init];
}

+ (void)startWatch:(NSString *)watchName blk:(ERStopWatchBlk)blk
{
    [self withLock:^{
        ERStopWatchModel *watch = [[ERStopWatchModel alloc] init];
        watch.startTick = [self tick];
        watch.offset = 0;
        watch.state = ERStopWatchStateStart;
        watches[watchName] = watch;

        NSLog(@"------------- %@ : start", watchName);
        if (blk) blk(ERStopWatchStateStart, watchName, 0);
    }];
}

+ (void)stopWatch:(NSString *)watchName blk:(ERStopWatchBlk)blk
{
    [self withLock:^{
        ERStopWatchModel *watch = watches[watchName];
        if (!watch) return;

        NSArray<NSNumber *> *timing = [self secondsAndTicksForWatch:watch];
        double seconds = timing.firstObject.doubleValue;

        watch.state = ERStopWatchStateStop;
        watch.seconds = seconds;

        NSLog(@"------------- %@ : stop, total time %lf", watchName, seconds);
        if (blk) blk(ERStopWatchStateStop, watchName, seconds);
    }];
}

+ (void)cutWatch:(NSString *)watchName blk:(ERStopWatchBlk)blk
{
    [self cutWatch:watchName tag:nil blk:blk];
}

+ (void)cutWatch:(NSString *)watchName tag:(NSString *)tag blk:(ERStopWatchBlk)blk
{
    [self withLock:^{
        ERStopWatchModel *watch = watches[watchName];
        if (!watch) return;

        double seconds = [self secondsAndTicksForWatch:watch].firstObject.doubleValue;

        NSLog(@"------------- %@ : cut, tag %@ , time from start %lf", watchName, tag ?: @"", seconds);
        if (blk) blk(watch.state, watchName, seconds);
    }];
}

+ (void)pauseWatch:(NSString *)watchName blk:(ERStopWatchBlk)blk
{
    [self withLock:^{
        ERStopWatchModel *watch = watches[watchName];
        if (!watch || watch.state != ERStopWatchStateStart) return;

        NSArray<NSNumber *> *timing = [self secondsAndTicksForWatch:watch];
        double seconds = timing.firstObject.doubleValue;
        watch.offset = timing.lastObject.unsignedLongLongValue;
        watch.state = ERStopWatchStatePause;

        NSLog(@"------------- %@ : pause , time from start %lf", watchName, seconds);
        if (blk) blk(ERStopWatchStatePause, watchName, seconds);
    }];
}

+ (void)resumeWatch:(NSString *)watchName blk:(ERStopWatchBlk)blk
{
    [self withLock:^{
        ERStopWatchModel *watch = watches[watchName];
        if (!watch || watch.state != ERStopWatchStatePause) return;

        watch.startTick = [self tick];
        watch.state = ERStopWatchStateStart;

        NSLog(@"------------- %@ : resume", watchName);
        if (blk) blk(ERStopWatchStateStart, watchName, 0);
    }];
}

+ (void)withLock:(dispatch_block_t)work
{
    [watchLock lock];
    @try {
        work();
    } @finally {
        [watchLock unlock];
    }
}

+ (UInt64)tick
{
    return mach_absolute_time();
}

+ (NSArray<NSNumber *> *)secondsAndTicksForWatch:(ERStopWatchModel *)watch
{
    static mach_timebase_info_data_t timebase;
    if (timebase.denom == 0) {
        mach_timebase_info(&timebase);
    }

    UInt64 ticks = watch.offset + [self tick] - watch.startTick;
    double seconds = (double)ticks * 1e-9 * (double)timebase.numer / (double)timebase.denom;
    return @[@(seconds), @(ticks)];
}

@end
