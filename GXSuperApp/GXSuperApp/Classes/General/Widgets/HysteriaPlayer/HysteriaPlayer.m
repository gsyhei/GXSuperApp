//
//  HysteriaPlayer.m
//
//  Created by saiday on 13/1/8.
//
//

#import "HysteriaPlayer.h"
#import <objc/runtime.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioSession.h>
#endif

static const void *Hysteriatag = &Hysteriatag;
NSString *const kHysteriaPlayerErrorContext = @"Context";
NSErrorDomain const HysteriaPlayerErrorDomain = @"com.streetvoice.HysteriaPlayer.error";

typedef NS_ENUM(NSInteger, PauseReason) {
    PauseReasonNone,
    PauseReasonForced,
    PauseReasonBuffering,
};

@interface HysteriaPlayer ()
{
    BOOL routeChangedWhilePlaying;
    BOOL interruptedWhilePlaying;
}
@property (nonatomic) HysteriaPlayerStatus hysteriaPlayerStatus;
@property (nonatomic) PauseReason pauseReason;

@end

@implementation HysteriaPlayer


static HysteriaPlayer *sharedInstance = nil;
static dispatch_once_t onceToken;

#pragma mark -
#pragma mark ===========  Initialization, Setup  =========
#pragma mark -

+ (HysteriaPlayer *)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)showAlertWithError:(NSError *)error
{
#if TARGET_OS_IPHONE
    if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:showAlertWithError:)]) {
        [self.delegate hysteriaPlayer:self showAlertWithError:error];
    }
#endif
}

- (id)init {
    self = [super init];
    if (self) {
        _hysteriaPlayerStatus = HysteriaPlayerStatusUnknown;
        _isLoopOnce = YES;
    }
    
    return self;
}

- (void)preActionUrlString:(NSString *)urlString
{
    self.audioPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:urlString]];
    if ([self.audioPlayer respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        self.audioPlayer.automaticallyWaitsToMinimizeStalling = YES;
    }
    self.audioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    if (self.audioPlayer.currentItem) {
        [self.audioPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.audioPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self backgroundPlayable];
    [self AVAudioSessionNotification];
}

- (void)backgroundPlayable
{
#if TARGET_OS_IPHONE
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (audioSession.category != AVAudioSessionCategoryPlayback) {
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            if (device.multitaskingSupported) {
                
                NSError *aError = nil;
                [audioSession setCategory:AVAudioSessionCategoryPlayback error:&aError];
                if (aError) {
                    if (!self.disableLogs) {
                        NSLog(@"HysteriaPlayer: set category error:%@",[aError description]);
                    }
                }
                aError = nil;
                [audioSession setActive:YES error:&aError];
                if (aError) {
                    if (!self.disableLogs) {
                        NSLog(@"HysteriaPlayer: set active error:%@",[aError description]);
                    }
                }
            }
        }
    } else {
        if (!self.disableLogs) {
            NSLog(@"HysteriaPlayer: unable to register background playback");
        }
    }
#endif
}

#pragma mark -
#pragma mark ===========  AVAudioSession Notifications  =========
#pragma mark -

- (void)AVAudioSessionNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemFailedToPlayToEndTime:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemPlaybackStall:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:nil];
    
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
#endif
    
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
}

#pragma mark -
#pragma mark ===========  Player Methods  =========
#pragma mark -

- (void)seekToTime:(double)seconds
{
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

- (void)seekToTime:(double)seconds withCompletionBlock:(void (^ _Nullable)(BOOL))completionBlock
{
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (completionBlock) {
            completionBlock(finished);
        }
    }];
}

- (void)play
{
    _pauseReason = PauseReasonNone;
    if (self.isAutoPlay) {
        [self.audioPlayer play];
    }
}

- (void)pause
{
    _pauseReason = PauseReasonForced;
    [self.audioPlayer pause];
}

- (CMTime)playerItemDuration
{
    NSError *err = nil;
    if ([self.audioPlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err] == AVKeyValueStatusLoaded) {
        AVPlayerItem *playerItem = [self.audioPlayer currentItem];
        NSArray *loadedRanges = playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0) {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            //Float64 duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            return (range.duration);
        } else {
            return (kCMTimeInvalid);
        }
    } else {
        return (kCMTimeInvalid);
    }
}

#pragma mark -
#pragma mark ===========  Player info  =========
#pragma mark -

- (BOOL)isPlaying
{
    return self.audioPlayer.rate != 0.f;
}

- (HysteriaPlayerStatus)getHysteriaPlayerStatus
{
    if ([self isPlaying]) {
        return HysteriaPlayerStatusPlaying;
    } else {
        switch (_pauseReason) {
            case PauseReasonForced:
                return HysteriaPlayerStatusForcePause;
            case PauseReasonBuffering:
                return HysteriaPlayerStatusBuffering;
            default:
                return HysteriaPlayerStatusUnknown;
        }
    }
}

- (float)getPlayingItemCurrentTime
{
    CMTime itemCurrentTime = [[self.audioPlayer currentItem] currentTime];
    float current = CMTimeGetSeconds(itemCurrentTime);
    if (CMTIME_IS_INVALID(itemCurrentTime) || !isfinite(current))
        return 0.0f;
    else
        return current;
}

- (float)getPlayingItemDurationTime
{
    CMTime itemDurationTime = [self playerItemDuration];
    float duration = CMTimeGetSeconds(itemDurationTime);
    if (CMTIME_IS_INVALID(itemDurationTime) || !isfinite(duration))
        return 0.0f;
    else
        return duration;
}

- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t)queue usingBlock:(void (^)(void))block
{
    id boundaryObserver = [self.audioPlayer addBoundaryTimeObserverForTimes:times queue:queue usingBlock:block];
    return boundaryObserver;
}

- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block
{
    id mTimeObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
    return mTimeObserver;
}

- (void)removeTimeObserver:(id)observer
{
    @try {
        [self.audioPlayer removeTimeObserver:observer];
    } @catch(id anException) {
        //do nothing, this could be "An instance of AVPlayer cannot remove a time observer that was added by a different instance of AVPlayer."
    }
}

#pragma mark -
#pragma mark ===========  Interruption, Route changed  =========
#pragma mark -

- (void)interruption:(NSNotification*)notification
{
#if TARGET_OS_IPHONE
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan && _pauseReason != PauseReasonForced) {
        interruptedWhilePlaying = YES;
        [self pause];
    } else if (interuptionType == AVAudioSessionInterruptionTypeEnded && interruptedWhilePlaying) {
        interruptedWhilePlaying = NO;
        [self play];
    }
    if (!self.disableLogs) {
        NSLog(@"HysteriaPlayer: HysteriaPlayer interruption: %@", interuptionType == AVAudioSessionInterruptionTypeBegan ? @"began" : @"end");
    }
#endif
}

- (void)routeChange:(NSNotification *)notification
{
#if TARGET_OS_IPHONE
    NSDictionary *routeChangeDict = notification.userInfo;
    NSInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && _pauseReason != PauseReasonForced) {
        routeChangedWhilePlaying = YES;
        [self pause];
    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable && routeChangedWhilePlaying) {
        routeChangedWhilePlaying = NO;
        [self play];
    }
    if (!self.disableLogs) {
        NSLog(@"HysteriaPlayer: HysteriaPlayer routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
    }
#endif
}

#pragma mark -
#pragma mark ===========  KVO  =========
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.audioPlayer.status == AVPlayerStatusReadyToPlay) {
            if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didReadyToPlayWithIdentifier:)]) {
                [self.delegate hysteriaPlayer:self didReadyToPlayWithIdentifier:HysteriaPlayerReadyToPlayPlayer];
            }
            if (![self isPlaying]) {
                [self play];
            }
        } else if (self.audioPlayer.status == AVPlayerStatusFailed) {
            if (!self.disableLogs) {
                NSLog(@"HysteriaPlayer: %@", self.audioPlayer.error);
            }
            
            if (self.popAlertWhenError) {
                [self showAlertWithError:self.audioPlayer.error];
            }
            
            if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didFailWithIdentifier:error:)]) {
                NSError *error = self.audioPlayer.error ? self.audioPlayer.error : [self unknownError];
                [self.delegate hysteriaPlayer:self didFailWithIdentifier:HysteriaPlayerFailedPlayer error:error];
            }
        }
    }
    
    if (object == self.audioPlayer && [keyPath isEqualToString:@"rate"]) {
        if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:rateDidChange:)]) {
            [self.delegate hysteriaPlayer:self rateDidChange:self.audioPlayer.rate];
        }
    }

    if (object == self.audioPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
        if (self.audioPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            [self.audioPlayer.currentItem cancelPendingSeeks];
            if (self.popAlertWhenError) {
                [self showAlertWithError:self.audioPlayer.currentItem.error];
            }
            
            if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didFailWithIdentifier:error:)]) {
                NSError *error = self.audioPlayer.currentItem.error ? self.audioPlayer.currentItem.error : [self unknownError];
                [self.delegate hysteriaPlayer:self didFailWithIdentifier:HysteriaPlayerFailedCurrentItem error:error];
            }
        } else if (self.audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didReadyToPlayWithIdentifier:)]) {
                [self.delegate hysteriaPlayer:self didReadyToPlayWithIdentifier:HysteriaPlayerReadyToPlayCurrentItem];
            }
            if (![self isPlaying] && _pauseReason != PauseReasonForced) {
                [self play];
            }
        }
    }

    if (object == self.audioPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            
            if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didPreloadCurrentItemWithTime:)]) {
                [self.delegate hysteriaPlayer:self didPreloadCurrentItemWithTime:CMTimeAdd(timerange.start, timerange.duration)];
            }
            
            if (self.audioPlayer.rate == 0 && _pauseReason != PauseReasonForced) {
                _pauseReason = PauseReasonBuffering;                
                CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
                CMTime milestone = CMTimeAdd(self.audioPlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));

                if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone) && self.audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && !interruptedWhilePlaying && !routeChangedWhilePlaying) {
                    if (![self isPlaying]) {
                        if (!self.disableLogs) {
//                            NSLog(@"HysteriaPlayer: resume from buffering..");
                        }
                        [self play];
                    }
                }
                else {
                    if (!self.disableLogs) {
                        NSLog(@"HysteriaPlayer: resume from buffering < 5.0s...");
                    }
                }
            }
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *item = [notification object];
    if (![item isEqual:self.audioPlayer.currentItem]) {
        return;
    }
    if (self.isLoopOnce) {
        [self seekToTime:0];
        [self play];
    }
    else {
        [self pause];
        if ([self.delegate respondsToSelector:@selector(hysteriaPlayerDidReachEnd:)]) {
            [self.delegate hysteriaPlayerDidReachEnd:self];
        }
    }
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    if (![item isEqual:self.audioPlayer.currentItem]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didFailedWithPlayerItem:toPlayToEndTimeWithError:)]) {
        NSError *itemFailedToPlayToEndTimeError = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
        NSError *error = itemFailedToPlayToEndTimeError ? itemFailedToPlayToEndTimeError : [self unknownError];
        [self.delegate hysteriaPlayer:self didFailedWithPlayerItem:item toPlayToEndTimeWithError:error];
    }
}

- (void)playerItemPlaybackStall:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    if (![item isEqual:self.audioPlayer.currentItem]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(hysteriaPlayer:didStallWithPlayerItem:)]) {
        [self.delegate hysteriaPlayer:self didStallWithPlayerItem:item];
    }
}

- (NSError *)unknownError
{
    return [[NSError alloc] initWithDomain:HysteriaPlayerErrorDomain code:0 userInfo:@{kHysteriaPlayerErrorContext : @"unknown error"}];
}

#pragma mark -
#pragma mark ===========   Deprecation  =========
#pragma mark -

- (void)deprecatePlayer
{
#if TARGET_OS_IPHONE
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    if (error) {
        if (!self.disableLogs) {
            NSLog(@"HysteriaPlayer: set category error:%@", [error localizedDescription]);
        }
    }
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.audioPlayer.currentItem) {
        [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
        [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    }
    [self.audioPlayer removeObserver:self forKeyPath:@"status" context:nil];
    [self.audioPlayer removeObserver:self forKeyPath:@"rate" context:nil];

    [self.audioPlayer pause];
    self.delegate = nil;
    self.audioPlayer = nil;
    
    onceToken = 0;
}

@end
