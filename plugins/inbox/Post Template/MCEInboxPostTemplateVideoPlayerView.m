/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxPostTemplateVideoPlayerView.h"

@interface MCEInboxPostTemplateVideoPlayerView ()
@property AVPlayerLayer *playerLayer;
@end

@implementation MCEInboxPostTemplateVideoPlayerView

- (void)layoutSubviews
{
    self.playerLayer.frame = self.bounds;
}

-(void)loadVideoPlayer:(AVPlayer*)player
{
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
}

-(void)unloadVideoPlayer
{
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
}

@end
