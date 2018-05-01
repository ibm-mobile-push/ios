/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import AVFoundation;
@import UIKit;
#else
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#endif

@interface MCEInboxPostTemplateVideoPlayerView : UIButton
-(void)loadVideoPlayer:(AVPlayer*)player;
-(void)unloadVideoPlayer;
@end
