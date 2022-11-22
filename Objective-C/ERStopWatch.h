//
//  ERStopWatch.h
//
//  Created by Zhang Zhicheng on 12-8-27.

//

@import Foundation;

typedef enum
{
    ERStopWatchStateStart,
    ERStopWatchStatePause,
    ERStopWatchStateStop,
} ERStopWatchState;

typedef void (^ERStopWatchBlk)(ERStopWatchState state, NSString * _Nonnull watchName, double_t nanos);

@interface ERStopWatch : NSObject

+ (void)startWatch: (NSString * _Nonnull)watchName blk:(ERStopWatchBlk _Nullable)blk;
+ (void)stopWatch: (NSString * _Nonnull)watchName blk:(ERStopWatchBlk _Nullable)blk;

+ (void)cutWatch: (NSString * _Nonnull)watchName tag: (NSString * _Nullable)tag blk:(ERStopWatchBlk _Nullable)blk;
+ (void)cutWatch: (NSString * _Nonnull)watchName blk:(ERStopWatchBlk _Nullable)blk;

+ (void)pauseWatch: (NSString * _Nonnull)watchName blk:(ERStopWatchBlk _Nullable)blk;
+ (void)resumeWatch: (NSString * _Nonnull)watchName blk:(ERStopWatchBlk _Nullable)blk;

@end
