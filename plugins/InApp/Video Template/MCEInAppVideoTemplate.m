/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInAppVideoTemplate.h"
@import AVFoundation;

@interface MCEInAppVideoTemplate ()
@property AVPlayer * player;

// Only used for disabling vibrantancy selectively
@property UIProgressView * progressView;
@property UIProgressView * foreProgressView;

@property id periodicObserver;
@property id boundaryObserver;

@end

@implementation MCEInAppVideoTemplate

// Used when text is expanded or contracted, hides foreground elements if collapsed. This is due to the vibrant labels not being able to expand over the non vibrant content image.
-(void)setTextHeight
{
    [super setTextHeight];
    [UIView animateWithDuration:0.25 animations:^{
        if(self.textLabel.titleLabel.numberOfLines == 2)
        {
            self.foreTextLabel.alpha = 0.1;
            self.foreTitleLabel.alpha = 0.1;
            self.contentView.alpha = 1;
        }
        else
        {
            self.foreTextLabel.alpha = 1;
            self.foreTitleLabel.alpha = 1;
            self.contentView.alpha = 0.5;
        }
        
        [self.foreProgressView layoutIfNeeded];
        [self.progressView layoutIfNeeded];
    }];
}

-(void)unloadVideo
{
    [self.player removeTimeObserver: self.periodicObserver];
    [self.player removeTimeObserver: self.boundaryObserver];

    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player pause];
    self.player = nil;
    MCEInAppVideoPlayerView * playerView = (MCEInAppVideoPlayerView *)self.contentView;
    [playerView unloadVideoPlayer];
}

-(IBAction)dismiss: (id)sender
{
    [self unloadVideo];
    [super dismiss:sender];
}

-(void)displayInAppMessage:(MCEInAppMessage*)message
{
    [super displayInAppMessage:message];
    
    self.progressView = (UIProgressView *)self.textLine;
    self.progressView.progress=0;
    self.foreProgressView.progress = 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"status"])
    {
        if(self.player.status == AVPlayerStatusFailed)
        {
            [self dismiss:self];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadVideo];
}

-(void)loadVideo
{
    NSURL * url = [NSURL URLWithString:self.inAppMessage.content[@"video"]];
    
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL: url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoDismiss:) name:AVPlayerItemDidPlayToEndTimeNotification object: playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.periodicObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"MCEInAppVideoProgress" object:nil];
    }];
    
    self.boundaryObserver = [self.player addBoundaryTimeObserverForTimes: @[[NSValue valueWithCMTime:CMTimeMake(1, 3)]] queue:dispatch_get_main_queue() usingBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCEInAppVideoStart"object:nil];
    }];
    
    
    MCEInAppVideoPlayerView * playerView = (MCEInAppVideoPlayerView *)self.contentView;
    [playerView loadVideoPlayer:self.player];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.player play];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.progressView = (UIProgressView *)self.textLine;

    if([self isBlurAvailable])
    {

        self.foreProgressView = [self.foreContainerView viewWithTag:2];
        self.contentView = [self.foreContainerView viewWithTag:3];
        [self.contentView addTarget:self action:@selector(execute:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advanceProgress:) name: @"MCEInAppVideoProgress" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startVideo:) name: @"MCEInAppVideoStart" object:nil];
        
    }
    return self;
}

-(void)startVideo:(NSNotification*)note
{
    [self.spinner stopAnimating];
}

-(void)advanceProgress: (NSNotification*)note
{
    CMTime current = self.player.currentTime;
    CMTime total = self.player.currentItem.duration;
    if(current.timescale == 0 || total.timescale == 0)
    {
        return;
    }
    
    float progress = (float)(current.value/current.timescale) / (total.value/total.timescale);
    [self.progressView setProgress:progress animated:false];
    [self.foreProgressView setProgress:progress animated:false];
}

+(void) registerTemplate
{
    [[MCEInAppTemplateRegistry sharedInstance] registerTemplate:@"video" hander:[[self alloc] initWithNibName: @"MCEInAppVideoTemplate" bundle: nil]];
}


@end
