//
//  ERStopWatch.h
//  Nutricia
//
//  Created by Zhang Zhicheng on 12-8-27.

//

#import <Foundation/Foundation.h>

typedef enum
{
    ERStopWatchLogTypeNone      = 0,
    ERStopWatchLogTypeStart     = 1 << 0,
    ERStopWatchLogTypeStop      = 1 << 1
} ERStopWatchLogType;

typedef enum
{
    ERStopWatchStateStart       = 0,
    ERStopWatchStatePause       = 1,
    ERStopWatchStateStop        = 2
} ERStopWatchState;

@interface ERStopWatch : NSObject
{
    NSMutableDictionary *_stopWatchDictionary;
    
}

+ (NSTimeInterval)startWatch: (NSString *)watchName;

+ (NSTimeInterval)stopWatch: (NSString *)watchName;

+ (NSTimeInterval)cutWatch: (NSString *)watchName;

+ (NSTimeInterval)pauseWatch: (NSString *)watchName;

+ (NSTimeInterval)resumeWatch: (NSString *)watchName;

@end
