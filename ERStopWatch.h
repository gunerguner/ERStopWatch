//
//  ERStopWatch.h
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

+ (void)startWatch: (NSString *)watchName;

+ (void)stopWatch: (NSString *)watchName;

+ (void)cutWatch: (NSString *)watchName tag: (NSString *)tag;
+ (void)cutWatch: (NSString *)watchName;

+ (void)pauseWatch: (NSString *)watchName;

+ (void)resumeWatch: (NSString *)watchName;

@end
