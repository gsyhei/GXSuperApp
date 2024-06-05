//
//  HysteriaPlayer.h
//
//  Version 1.0
//
//  Created by Saiday on 01/14/2013.
//  Copyright 2013 StreetVoice
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <AvailabilityMacros.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HysteriaPlayerReadyToPlay) {
    HysteriaPlayerReadyToPlayPlayer = 3000,
    HysteriaPlayerReadyToPlayCurrentItem = 3001,
};

typedef NS_ENUM(NSInteger, HysteriaPlayerFailed) {
    HysteriaPlayerFailedPlayer = 4000,
    HysteriaPlayerFailedCurrentItem = 4001,
};

@class HysteriaPlayer;

/**
 *  HysteriaPlayerDelegate, all delegate method is optional.
 */
@protocol HysteriaPlayerDelegate <NSObject>

@optional
- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer rateDidChange:(float)rate;
- (void)hysteriaPlayerDidReachEnd:(HysteriaPlayer *)hysteriaPlayer;
- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer didPreloadCurrentItemWithTime:(CMTime)time;
- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer didFailWithIdentifier:(HysteriaPlayerFailed)identifier error:(NSError *)error;
- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer didReadyToPlayWithIdentifier:(HysteriaPlayerReadyToPlay)identifier;

- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer didFailedWithPlayerItem:(AVPlayerItem * _Nullable)item toPlayToEndTimeWithError:(NSError *)error;
- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer didStallWithPlayerItem:(AVPlayerItem * _Nullable)item;
- (void)hysteriaPlayer:(HysteriaPlayer *)hysteriaPlayer showAlertWithError:(NSError *)error;

@end

typedef NS_ENUM(NSInteger, HysteriaPlayerStatus) {
    HysteriaPlayerStatusPlaying = 0,
    HysteriaPlayerStatusForcePause,
    HysteriaPlayerStatusBuffering,
    HysteriaPlayerStatusUnknown,
};

@interface HysteriaPlayer : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong, nullable) AVPlayer *audioPlayer;
@property (nonatomic, weak, nullable) id<HysteriaPlayerDelegate> delegate;
@property (nonatomic) BOOL disableLogs;
@property (nonatomic) BOOL popAlertWhenError;
@property (nonatomic, assign) BOOL isAutoPlay;
@property (nonatomic, assign) BOOL isLoopOnce;

+ (HysteriaPlayer *)sharedInstance;
- (void)preActionUrlString:(NSString *)urlString;

- (void)play;
- (void)pause;
- (void)seekToTime:(double)CMTime;
- (void)seekToTime:(double)CMTime withCompletionBlock:(void (^ _Nullable)(BOOL finished))completionBlock;

- (BOOL)isPlaying;
- (HysteriaPlayerStatus)getHysteriaPlayerStatus NS_SWIFT_NAME(status());

- (float)getPlayingItemCurrentTime NS_SWIFT_NAME(playingItemCurrentTime());
- (float)getPlayingItemDurationTime NS_SWIFT_NAME(playingItemDurationTime());
- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t _Nullable)queue usingBlock:(void (^)(void))block;
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t _Nullable)queue usingBlock:(void (^)(CMTime time))block;
- (void)removeTimeObserver:(id)observer;

- (void)deprecatePlayer;

@end

NS_ASSUME_NONNULL_END
