//
//  ERStopWatch.m
//  Nutricia
//
//  Created by Zhang Zhicheng on 12-8-27.

//

#import "ERStopWatch.h"

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

+ (NSTimeInterval)startWatch: (NSString *)watchName
{
    if (!_instance) {
        _instance = [[ERStopWatch alloc] init];
    }
    
    return [_instance startWatch:watchName shouldLog:(logType & ERStopWatchLogTypeStart)];
}

+ (NSTimeInterval)stopWatch: (NSString *)watchName
{
    if (!_instance) {
        return 0;
    }
    
    return [_instance stopWatch:watchName shouldLog:(logType & ERStopWatchLogTypeStop)];
}

+ (NSTimeInterval)cutWatch: (NSString *)watchName
{
    if ((!_instance)||(logType == ERStopWatchLogTypeNone)) {
        return 0;
    }
    
    return [_instance cutWatch:watchName];
}

+ (NSTimeInterval)pauseWatch: (NSString *)watchName
{
    if ((!_instance)||(logType == ERStopWatchLogTypeNone)) {
        return 0;
    }
    
    return [_instance pauseWatch:watchName shouldLog:(logType != ERStopWatchLogTypeNone)];
}

+ (NSTimeInterval)resumeWatch: (NSString *)watchName
{
    if ((!_instance)||(logType == ERStopWatchLogTypeNone)) {
        return 0;
    }
    
    return [_instance resumeWatch:watchName shouldLog:(logType != ERStopWatchLogTypeNone)];
}

- (NSTimeInterval)startWatch: (NSString *)watchName
                   shouldLog: (BOOL)shouldLog
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    if ([_stopWatchDictionary objectForKey:watchName]) {
        [_stopWatchDictionary removeObjectForKey:watchName];
    }
    
    NSMutableDictionary *singleWatch = [NSMutableDictionary dictionary];
    
    [singleWatch setObject:[NSNumber numberWithDouble:0] forKey:@"offset"];
    [singleWatch setObject:[NSNumber numberWithDouble:timeStamp] forKey:@"startStamp"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStart] forKey:@"state"];
    
    [_stopWatchDictionary setObject:singleWatch forKey:watchName];
    
    if (shouldLog) {
        NSLog(@"------------- %@ : start at %lf",watchName, timeStamp);
    }
    
    return timeStamp;

}

- (NSTimeInterval)stopWatch: (NSString *)watchName
                  shouldLog: (BOOL)shouldLog
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    [singleWatch setObject:[NSNumber numberWithDouble:timeStamp] forKey:@"stopStamp"];;
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStop] forKey:@"state"];
    
    NSTimeInterval timeInterval = [[singleWatch objectForKey:@"offset"] doubleValue] + ( timeStamp - [[singleWatch objectForKey:@"startStamp"] doubleValue]);
    
    if (shouldLog) {
        NSLog(@"------------- %@ : stop at %lf, total time %lf",watchName, timeStamp, timeInterval);
    }
    
    return timeStamp;
}

- (NSTimeInterval)cutWatch: (NSString *)watchName
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    NSTimeInterval timeInterval = [[singleWatch objectForKey:@"offset"] doubleValue] + ( timeStamp - [[singleWatch objectForKey:@"startStamp"] doubleValue]);
    
    NSLog(@"------------- %@ : cut at %lf, time from start %lf",watchName,timeStamp, timeInterval);
    
    return timeStamp;
}

- (NSTimeInterval)pauseWatch: (NSString *)watchName
                 shouldLog: (BOOL)shouldLog
{
    
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    if ([[singleWatch objectForKey:@"state"] intValue] != ERStopWatchStateStart) {
        return 0;
    }
    
    NSTimeInterval timeInterval = [[singleWatch objectForKey:@"offset"] doubleValue] + ( timeStamp - [[singleWatch objectForKey:@"startStamp"] doubleValue] );
    
    [singleWatch setObject:[NSNumber numberWithDouble:timeInterval] forKey:@"offset"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStatePause] forKey:@"state"];
    
    if (shouldLog) {
        NSLog(@"------------- %@ : pause at %lf, time from start %lf",watchName, timeStamp, timeInterval);
    }
    
    return timeStamp;
}

- (NSTimeInterval)resumeWatch: (NSString *)watchName
                 shouldLog: (BOOL)shouldLog
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *singleWatch = [_stopWatchDictionary objectForKey:watchName];
    
    if ([[singleWatch objectForKey:@"state"] intValue] != ERStopWatchStatePause) {
        return 0;
    }
    
    [singleWatch setObject:[NSNumber numberWithDouble:timeStamp] forKey:@"startStamp"];
    [singleWatch setObject:[NSNumber numberWithInt:ERStopWatchStateStart] forKey:@"state"];
    
    if (shouldLog) {
        NSLog(@"------------- %@ : resume at %lf ",watchName, timeStamp);
    }
    
    return timeStamp;
}

@end
