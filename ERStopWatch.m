//
//  ERStopWatch.m
//
//  Created by Zhang Zhicheng on 12-8-27.

//

#import "ERStopWatch.h"
#import <mach/mach_time.h>


@implementation ERStopWatch

static ERStopWatch *_instance;

#ifdef DEBUG
static ERStopWatchLogType logType = ERStopWatchLogTypeStart | ERStopWatchLogTypeStop;
#else
static ERStopWatchLogType logType = ERStopWatchLogTypeNone;
#endif

- (id)init
{
    
    self = [super init];
    if (self)
    {
        _stopWatchDictionary = [[NSMutableDictionary alloc] init];
        
        
    }
    
    return self;
    
}

+ (void)startWatch: (NSString *)watchName
{
    if (!_instance) {
        _instance = [[ERStopWatch alloc] init];
    }
    
    [_instance startWatch:watchName shouldLog:(logType & ERStopWatchLogTypeStart)];
}

+ (void)stopWatch: (NSString *)watchName
{
    if (!_instance) {
        return ;
    }
    
    [_instance stopWatch:watchName shouldLog:(logType & ERStopWatchLogTypeStop)];
}

+ (void)cutWatch: (NSString *)watchName tag: (NSString *)tag
{
    if ((!_instance)||(logType == ERStopWatchLogTypeNone)) {
        return ;
    }
    
    [_instance cutWatch:watchName tag:tag];

}


+ (void)cutWatch: (NSString *)watchName
{
    [self cutWatch:watchName tag: nil];
}

+ (void)pauseWatch: (NSString *)watchName
{
    if ((!_instance)||(logType == ERStopWatchLogTypeNone)) {
        return ;
    }
    
    [_instance pauseWatch:watchName shouldLog:(logType != ERStopWatchLogTypeNone)];
}

+ (void)resumeWatch: (NSString *)watchName
{
    if ((!_instance)||(logType == ERStopWatchLogTypeNone)) {
        return ;
    }
    
    [_instance resumeWatch:watchName shouldLog:(logType != ERStopWatchLogTypeNone)];
}

- (void)startWatch: (NSString *)watchName
         shouldLog: (BOOL)shouldLog
{
//    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    uint64_t start = mach_absolute_time();
    
    if ([_stopWatchDictionary objectForKey:watchName]) {
        [_stopWatchDictionary removeObjectForKey:watchName];
    }
    
    NSMutableDictionary *singleWatch = [NSMutableDictionary dictionary];
    
    [singleWatch setObject:[NSNumber numberWithDouble:0] forKey:@"offset"];
//    [singleWatch setObject:[NSNumber numberWithDouble:timeStamp] forKey:@"startStamp"];
    
    [singleWatch setObject:[NSNumber numberWithLongLong:start] forKey:@"startStampMach"];
    
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStart] forKey:@"state"];
    
    [_stopWatchDictionary setObject:singleWatch forKey:watchName];
    
    
    
    if (shouldLog) {
        NSLog(@"------------- %@ : start",watchName);
    }
    
    return;

}

- (void)stopWatch: (NSString *)watchName
        shouldLog: (BOOL)shouldLog
{
//    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    uint64_t stop = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    [singleWatch setObject:[NSNumber numberWithLongLong:stop] forKey:@"stopStampMach"];
//    [singleWatch setObject:[NSNumber numberWithDouble:timeStamp] forKey:@"stopStamp"];;
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStop] forKey:@"state"];
    
    
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    
    
    uint64_t timeInt = [[singleWatch objectForKey:@"offset"] longLongValue] + stop - [[singleWatch objectForKey:@"startStampMach"] longLongValue];
    
    uint64_t elapsedNano = timeInt * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    double_t nanos = (double_t)elapsedNano * 1e-9;
    
    
    if (shouldLog) {
        NSLog(@"------------- %@ : stop, total time %lf",watchName,nanos);
    }
    
    return;
}



- (void)cutWatch: (NSString *)watchName tag: (NSString *)tag
{
    uint64_t stop = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    //    NSTimeInterval timeInterval = [[singleWatch objectForKey:@"offset"] doubleValue] + ( timeStamp - [[singleWatch objectForKey:@"startStamp"] doubleValue]);
    
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    
    uint64_t timeInt = [[singleWatch objectForKey:@"offset"] longLongValue] + stop - [[singleWatch objectForKey:@"startStampMach"] longLongValue];
    
    uint64_t elapsedNano = timeInt * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    double_t nanos = (double_t)elapsedNano * 1e-9;
    
    if (!tag) {
        tag = @"";
    }
    
    NSLog(@"------------- %@ : cut, tag %@ , time from start %lf",watchName, tag, nanos);
    
    return;

}


- (void)pauseWatch: (NSString *)watchName
         shouldLog: (BOOL)shouldLog
{
    
    uint64_t stop = mach_absolute_time();
//    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    if ([[singleWatch objectForKey:@"state"] intValue] != ERStopWatchStateStart) {
        return ;
    }
    
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    
    uint64_t timeInt = [[singleWatch objectForKey:@"offset"] longLongValue] + stop - [[singleWatch objectForKey:@"startStampMach"] longLongValue];

    uint64_t elapsedNano = timeInt * sTimebaseInfo.numer / sTimebaseInfo.denom;
    
    double_t nanos = (double_t)elapsedNano * 1e-9;
    
    
//    NSTimeInterval timeInterval = [[singleWatch objectForKey:@"offset"] doubleValue] + ( timeStamp - [[singleWatch objectForKey:@"startStamp"] doubleValue] );
    
    [singleWatch setObject:[NSNumber numberWithLongLong:timeInt] forKey:@"offset"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStatePause] forKey:@"state"];
    
    if (shouldLog) {
        NSLog(@"------------- %@ : pause , time from start %lf",watchName, nanos);
    }
    
    return;
}

- (void)resumeWatch: (NSString *)watchName
          shouldLog: (BOOL)shouldLog
{
//    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    uint64_t start = mach_absolute_time();
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    if ([[singleWatch objectForKey:@"state"] intValue] != ERStopWatchStatePause) {
        return;
    }
    
    [singleWatch setObject:[NSNumber numberWithLongLong:start] forKey:@"startStampMach"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStart] forKey:@"state"];
    
    if (shouldLog) {
        NSLog(@"------------- %@ : resume  ",watchName);
    }
    
    return;
}

@end
