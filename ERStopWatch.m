//
//  ERStopWatch.m
//
//  Created by Zhang Zhicheng on 12-8-27.

//

#import "ERStopWatch.h"
#import <mach/mach_time.h>

@interface ERStopWatchModel : NSObject

@property (nonatomic, assign) UInt64 startStampMach;
@property (nonatomic, assign) double_t nanos;
@property (nonatomic, assign) UInt64 offset;
@property (nonatomic, assign) ERStopWatchState state;

@end

@implementation ERStopWatchModel

@end

@implementation ERStopWatch

static NSMutableDictionary<NSString *, ERStopWatchModel *> *_stopWatchDictionary;

+ (void)startWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary) {
        _stopWatchDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if ([_stopWatchDictionary objectForKey:watchName]) {
        [_stopWatchDictionary removeObjectForKey:watchName];
    }
    
    ERStopWatchModel *model = [[ERStopWatchModel alloc] init];
    model.startStampMach = mach_absolute_time();
    model.offset = 0;
    model.state = ERStopWatchStateStart;
    
    [_stopWatchDictionary setObject:model forKey:watchName];

    NSLog(@"------------- %@ : start",watchName);
    blk?blk(ERStopWatchStateStart,watchName,0):nil;
    
    return;
}

+ (void)stopWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary)  return;
    
    ERStopWatchModel *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    if (!singleWatch)   return;
    
    double nanos = [[[self _nanoWithWatch:singleWatch] firstObject] doubleValue];
    
    singleWatch.state = ERStopWatchStateStop;
    singleWatch.nanos = nanos;
    
    NSLog(@"------------- %@ : stop, total time %lf",watchName,nanos);
    blk?blk(ERStopWatchStateStop,watchName,nanos):nil;
    
}

+ (void)cutWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    [self cutWatch:watchName tag: nil blk:(ERStopWatchBlk _Nullable)blk];
}

+ (void)cutWatch: (nonnull NSString *)watchName tag: (nullable NSString *)tag blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary)  return;
    
    ERStopWatchModel *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    if (!singleWatch)   return;
    
    double nanos = [[[self _nanoWithWatch:singleWatch] firstObject] doubleValue];
    
    NSLog(@"------------- %@ : cut, tag %@ , time from start %lf",watchName, tag?:@"", nanos);
    blk?blk(ERStopWatchStateStart,watchName,nanos):nil;
    
}


+ (void)pauseWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary) return ;
    
    ERStopWatchModel *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    if (!singleWatch || singleWatch.state != ERStopWatchStateStart)   return;
    
    NSArray *nanosArray = [self _nanoWithWatch:singleWatch];
    
    singleWatch.offset = [nanosArray[1] intValue];
    singleWatch.state = ERStopWatchStatePause;

    double nanos = [[nanosArray firstObject] doubleValue];
    
    NSLog(@"------------- %@ : pause , time from start %lf",watchName, nanos);
    blk?blk(ERStopWatchStatePause,watchName,nanos):nil;
}

+ (void)resumeWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk
{
    if (!_stopWatchDictionary)  return ;
    
    uint64_t start = mach_absolute_time();
    
    ERStopWatchModel *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    if (!singleWatch || singleWatch.state != ERStopWatchStatePause)   return;
    
    singleWatch.startStampMach = start;
    singleWatch.state = ERStopWatchStateStart;
    
    NSLog(@"------------- %@ : resume  ",watchName);
    blk?blk(ERStopWatchStateStart,watchName,0):nil;
}

+ (NSArray *)_nanoWithWatch: (ERStopWatchModel *)singleWatch
{
    
    static mach_timebase_info_data_t sTimebaseInfo;
    mach_timebase_info(&sTimebaseInfo);
    
    UInt64 timeInt = singleWatch.offset + mach_absolute_time() - singleWatch.startStampMach;
    double nanos = timeInt * 1e-9 * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    return @[@(nanos), @(timeInt)];
}

@end
