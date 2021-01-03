//
//  ERStopWatch.m
//
//  Created by Zhang Zhicheng on 12-8-27.

//

#import "ERStopWatch.h"
#import <mach/mach_time.h>

@implementation ERStopWatch

static NSMutableDictionary *_stopWatchDictionary;

+ (void)startWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary) {
        _stopWatchDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if ([_stopWatchDictionary objectForKey:watchName]) {
        [_stopWatchDictionary removeObjectForKey:watchName];
    }
    
    uint64_t start = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [[NSMutableDictionary alloc] init];
    
    [singleWatch setObject:[NSNumber numberWithLongLong:0] forKey:@"offset"];
    [singleWatch setObject:[NSNumber numberWithLongLong:start] forKey:@"startStampMach"];
    [singleWatch setObject:@(ERStopWatchStateStart) forKey:@"state"];
    
    [_stopWatchDictionary setObject:singleWatch forKey:watchName];

    NSLog(@"------------- %@ : start",watchName);
    blk?blk(ERStopWatchStateStart,watchName,0):nil;
    
    return;
}

+ (void)stopWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary)  return;
    
    uint64_t stop = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    [singleWatch setObject:[NSNumber numberWithLongLong:stop] forKey:@"stopStampMach"];
    [singleWatch setObject:@(ERStopWatchStateStop) forKey:@"state"];
    
    static mach_timebase_info_data_t sTimebaseInfo;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    uint64_t timeInt = [[singleWatch objectForKey:@"offset"] longLongValue] + stop - [[singleWatch objectForKey:@"startStampMach"] longLongValue];
    
    uint64_t elapsedNano = timeInt * sTimebaseInfo.numer / sTimebaseInfo.denom;
    double_t nanos = (double_t)elapsedNano * 1e-9;
    
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
    
    uint64_t stop = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    if (!singleWatch)   return;
    
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    uint64_t timeInt = [[singleWatch objectForKey:@"offset"] longLongValue] + stop - [[singleWatch objectForKey:@"startStampMach"] longLongValue];
    
    uint64_t elapsedNano = timeInt * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    double_t nanos = (double_t)elapsedNano * 1e-9;
    
    NSLog(@"------------- %@ : cut, tag %@ , time from start %lf",watchName, tag?:@"", nanos);
    blk?blk(ERStopWatchStateStart,watchName,nanos):nil;
    
}


+ (void)pauseWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary) return ;
    
    uint64_t stop = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    if ([[singleWatch objectForKey:@"state"] intValue] != ERStopWatchStateStart)  return ;
    
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    uint64_t timeInt = [[singleWatch objectForKey:@"offset"] longLongValue] + stop - [[singleWatch objectForKey:@"startStampMach"] longLongValue];
    
    uint64_t elapsedNano = timeInt * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    double_t nanos = (double_t)elapsedNano * 1e-9;
    
    [singleWatch setObject:[NSNumber numberWithLongLong:timeInt] forKey:@"offset"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStatePause] forKey:@"state"];
    
    NSLog(@"------------- %@ : pause , time from start %lf",watchName, nanos);
    blk?blk(ERStopWatchStatePause,watchName,nanos):nil;
}

+ (void)resumeWatch: (nonnull NSString *)watchName blk:(ERStopWatchBlk _Nullable)blk;
{
    if (!_stopWatchDictionary)  return ;
    
    uint64_t start = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    if ([[singleWatch objectForKey:@"state"] intValue] != ERStopWatchStatePause) return;
    
    [singleWatch setObject:[NSNumber numberWithLongLong:start] forKey:@"startStampMach"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStart] forKey:@"state"];
    
    NSLog(@"------------- %@ : resume  ",watchName);
    blk?blk(ERStopWatchStateStart,watchName,0):nil;
}

@end
