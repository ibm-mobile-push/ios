/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxPostTemplateImage.h"
#import "MCEInboxPostTemplateView.h"

#if __has_feature(modules)
@import AVFoundation;
#else
#import <AVFoundation/AVFoundation.h>
#endif

const CGFloat UNKNOWN_IMAGE_HEIGHT = 100;
const CGSize HEADER_IMAGE_SIZE = {54, 54};
const int MARGIN = 8;

@interface MCEInboxPostTemplateView ()
@property dispatch_queue_t queue;
@property MCEInboxMessage * message;
@property id periodicObserver;
@property id boundaryObserver;
@property AVPlayer * player;
@property BOOL reload;

@property (nonatomic, copy) void (^resizeCallback)(CGSize size, NSURL * url, BOOL reload);
@end

@implementation MCEInboxPostTemplateView

-(void)awakeFromNib
{
    [super awakeFromNib];
    // Create a UIView from the nib and bind it to self.contentView
    [[NSBundle mainBundle] loadNibNamed:@"MCEInboxPostTemplateView" owner:self options:nil];
    [self addSubview:self.container];
    self.container.translatesAutoresizingMaskIntoConstraints=NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[visual]-0-|" options:0 metrics:@{} views:@{@"visual":self.container}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[visual]-0-|" options:0 metrics:@{} views:@{@"visual":self.container}]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStart:) name:@"MCEInboxPostTemplateVideoStart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoProgress:) name:@"MCEInboxPostTemplateVideoProgress" object:nil];
    self.queue = dispatch_queue_create("background", DISPATCH_QUEUE_CONCURRENT);
    [self prepareForReuse];
    
    self.contentImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)setInboxMessage:(MCEInboxMessage *)inboxMessage resizeCallback:(void (^)(CGSize, NSURL*, BOOL))resizeCallback
{
    self.reload = TRUE;
    self.resizeCallback = resizeCallback;
    self.message = inboxMessage;
    
    [self updateHeader];
    [self updateContent];
    [self updateActions];
    [self layoutSubviews];
}

-(void)prepareForReuse
{
    [self unloadVideo];
    
    self.resizeCallback = nil;
    self.message = nil;
    
    [self updateHeader];
    [self updateContent];
    [self updateActions];
    
    [self.headerActivity startAnimating];
}

#pragma mark Action Buttons

-(NSDictionary*)payload
{
    NSDictionary * payload = @{@"mce": [NSMutableDictionary dictionary]};
    if(self.message.attribution)
    {
        payload[@"mce"][@"attribution"] = self.message.attribution;
    }
    if(self.message.mailingId)
    {
        payload[@"mce"][@"mailingId"] = self.message.mailingId;
    }
    
    return payload;
}

-(IBAction)leftButton:(id)sender
{
    NSArray * actions = self.message.content[@"actions"];
    if(actions.count > 0)
    {
        [[MCEActionRegistry sharedInstance]performAction:actions[0] forPayload:self.payload source:InboxSource attributes:@{@"richContentId": self.message.richContentId, @"inboxMessageId": self.message.inboxMessageId}];
    }
}

-(IBAction)rightButton:(id)sender
{
    NSArray * actions = self.message.content[@"actions"];
    if(actions.count > 1)
    {
        [[MCEActionRegistry sharedInstance]performAction:actions[1] forPayload:self.payload source:InboxSource attributes:@{@"richContentId": self.message.richContentId, @"inboxMessageId": self.message.inboxMessageId}];
    }
}

-(IBAction)centerButton:(id)sender
{
    NSArray * actions = self.message.content[@"actions"];
    if(actions.count > 2)
    {
        [[MCEActionRegistry sharedInstance]performAction:actions[2] forPayload:self.payload source:InboxSource attributes:@{@"richContentId": self.message.richContentId, @"inboxMessageId": self.message.inboxMessageId}];
    }
}

-(void)updateActions
{
    NSArray * actions = self.message.content[@"actions"];
    if(actions)
    {
        self.actionMargin.constant = MARGIN;
        if([actions count] > 0) {
            [self.leftButton setTitle: actions[0][@"name"] forState:UIControlStateNormal];
        } else {
            [self.leftButton setTitle: @"" forState:UIControlStateNormal];
        }
        
        if([actions count] > 1) {
            [self.rightButton setTitle: actions[1][@"name"] forState:UIControlStateNormal];
        } else {
            [self.rightButton setTitle: @"" forState:UIControlStateNormal];
        }
        
        if([actions count] > 2) {
            [self.centerButton setTitle: actions[2][@"name"] forState:UIControlStateNormal];
        } else {
            [self.centerButton setTitle: @"" forState:UIControlStateNormal];
        }
    } else {
        self.actionMargin=0;
    }
}

#pragma mark Header

-(void)updateHeader
{
    self.header.text = self.message ? self.message.content[@"header"] : @"";
    self.subHeader.text = self.message ? self.message.content[@"subHeader"] : @"";
    [self updateHeaderImage];
}

-(void)updateHeaderImageData:(NSData*)data
{
    UIImage * image = nil;
    if(data)
    {
        image = [UIImage imageWithData:data];
    }
    [self.headerActivity stopAnimating];
    if(image)
    {
        self.headerMargin.constant = MARGIN;
        self.subheaderMargin.constant = MARGIN;
        [self resizeViewConstraints:self.headerImage size: HEADER_IMAGE_SIZE];
        self.headerImage.image = image;
    }
    else
    {
        self.headerMargin.constant = 0;
        self.subheaderMargin.constant = 0;
        [self resizeViewConstraints:self.headerImage size: CGSizeZero];
    }
}

-(void)updateHeaderImage
{
    if(!self.message || !self.message.content[@"headerImage"])
    {
        [self updateHeaderImageData: nil];
        return;
    }
    
    [self.headerActivity startAnimating];
    dispatch_async(self.queue, ^(){
        NSString * urlString = self.message.content[@"headerImage"];
        NSURL * url = [NSURL URLWithString:urlString];
        if(!url)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateHeaderImageData: nil];
            });
            return;
        }
        NSData * data = [MCEApiUtil cachedDataForUrl: url downloadIfRequired: TRUE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateHeaderImageData: data];
        });
    });
}

#pragma mark Content

-(void)updateContent
{
    [self updateContentText];
    
    [self resizeViewConstraints: self.videoPlay size: CGSizeZero];
    [self resizeViewConstraints: self.videoProgress size: CGSizeZero];
    
    NSString * videoUrlString = self.message ? self.message.content[@"contentVideo"] : nil;
    NSString * imageUrlString = self.message ? self.message.content[@"contentImage"] : nil;
    if(videoUrlString || imageUrlString)
    {
        if(videoUrlString)
        {
            [self.videoActivity startAnimating];
            NSURL * url = [NSURL URLWithString:videoUrlString];
            [self loadVideo: url];
            [self resizeViewConstraints:self.contentVideo contentUrl: url];
            self.contentImageView.alpha = 0;
            self.contentVideoView.alpha = 1;
        }
        else
        {
            self.contentImageView.alpha = 1;
            self.contentVideoView.alpha = 0;
            NSURL * url = [NSURL URLWithString:imageUrlString];
            [self resizeViewConstraints:self.contentImage contentUrl: url];
            
            NSData * imageData = [MCEApiUtil cachedDataForUrl: url downloadIfRequired: FALSE];
            if(imageData)
            {
                UIImage * image = [UIImage imageWithData:imageData];
                [self.contentImage setImage:image forState:UIControlStateNormal];
                self.resizeCallback(image.size, url, self.reload);
                [self resizeViewConstraints:self.contentImage contentUrl: url];
            }
            else
            {
                [self.contentActivity startAnimating];
                dispatch_async(self.queue, ^(){
                    NSData * data = [MCEApiUtil cachedDataForUrl: url downloadIfRequired: TRUE];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.contentActivity stopAnimating];
                        UIImage * image = [UIImage imageWithData:data];
                        [self.contentImage setImage:image forState:UIControlStateNormal];
                        self.resizeCallback(image.size, url, self.reload);
                        [self resizeViewConstraints:self.contentImage contentUrl: url];
                    });
                });
            }
        }
    }
    else
    {
        [self.videoActivity stopAnimating];
        [self.contentActivity stopAnimating];
        self.contentConstraint.constant = 0;
    }
}

-(IBAction)enlargeImage:(id)sender
{
    NSString * imageUrlString = self.message ? self.message.content[@"contentImage"] : nil;
    
    MCEInboxPostTemplateImage * viewController = [[MCEInboxPostTemplateImage alloc] initWithNibName:@"MCEInboxPostTemplateImage" bundle:nil imageUrlString: imageUrlString];
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:viewController animated:true completion:^{
    }];
    
}

#pragma mark Content Text

-(void)updateContentText
{
    CGFloat width = self.container.frame.size.width - MARGIN*2;
    self.contentText.text = self.message ? self.message.content[@"contentText"] : @"";
    CGRect contentTextSize = [self.contentText textRectForBounds:CGRectMake(0, 0, width, CGFLOAT_MAX) limitedToNumberOfLines: self.fullScreen ? 0 : 2];
    [self resizeViewConstraints:self.contentText size:contentTextSize.size];
}

#pragma mark Content Video

-(void)unloadVideo
{
    if(self.player)
    {
        [self.player removeTimeObserver: self.periodicObserver];
        [self.player removeTimeObserver: self.boundaryObserver];
        
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.player removeObserver:self forKeyPath:@"currentItem.presentationSize"];
        
        [self.player pause];
        self.player = nil;
        [self.contentVideo unloadVideoPlayer];
        
        self.boundaryObserver=nil;
        self.periodicObserver=nil;
    }
}

-(void)videoStart:(NSNotification*)note
{
    if(![note.userInfo[@"inboxMessageId"] isEqual:self.message.inboxMessageId])
    {
        return;
    }
    
    [self.videoActivity stopAnimating];
}

-(void)videoProgress:(NSNotification*)note
{
    if(![note.userInfo[@"inboxMessageId"] isEqual:self.message.inboxMessageId])
    {
        return;
    }
    
    [self.videoActivity stopAnimating];
    
    CMTime current = self.player.currentTime;
    CMTime total = self.player.currentItem.duration;
    if(current.timescale == 0 || total.timescale == 0)
    {
        return;
    }
    
    float progress = (float)(current.value/current.timescale) / (total.value/total.timescale);
    self.videoProgress.progress=progress;
}

-(void)videoFinished:(NSNotification*)note
{
    [self.player pause];
    self.videoPlay.alpha = 1;
    self.videoCover.alpha = 1;
    [self.videoActivity stopAnimating];
    [self.player seekToTime:CMTimeMake(0,1)];
}

-(void)loadVideo:(NSURL*)url
{
    CGFloat width = self.container.frame.size.width - MARGIN*2;
    [self resizeViewConstraints: self.videoPlay size: self.videoPlay.image.size];
    [self resizeViewConstraints: self.videoProgress size: CGSizeMake(width, 2)];
    
    self.videoPlay.alpha = 1;
    self.videoCover.alpha = 1;
    self.videoProgress.alpha = 1;
    self.videoProgress.progress=0;
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL: url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object: playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.contentVideo loadVideoPlayer:self.player];
    
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.player addObserver:self forKeyPath:@"currentItem.presentationSize" options:NSKeyValueObservingOptionNew context:NULL];
    
    NSString * inboxMessageId = self.message.inboxMessageId;
    self.periodicObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"MCEInboxPostTemplateVideoProgress" object:nil userInfo:@{@"inboxMessageId":inboxMessageId}];
    }];
    self.boundaryObserver = [self.player addBoundaryTimeObserverForTimes: @[[NSValue valueWithCMTime:CMTimeMake(1, 3)]] queue:dispatch_get_main_queue() usingBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCEInboxPostTemplateVideoStart" object:nil userInfo:@{@"inboxMessageId":inboxMessageId}];
    }];
}

-(IBAction)startVideo:(id)sender
{
    if(self.player.rate)
    {
        [self.player pause];
        self.videoPlay.alpha = 1;
        self.videoCover.alpha = 1;
        [self.videoActivity stopAnimating];
    }
    else
    {
        [self.player play];
        [self.videoActivity startAnimating];
        self.videoPlay.alpha = 0;
        self.videoCover.alpha = 0;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"status"])
    {
        if(self.player.status == AVPlayerStatusReadyToPlay)
        {
            [self.videoActivity stopAnimating];
        }
    }
    if([keyPath isEqual:@"currentItem.presentationSize"])
    {
        CGSize videoSize = self.player.currentItem.presentationSize;
        if(videoSize.width == 0 || videoSize.height == 0)
        {
            return;
        }
        
        NSURL * url = [NSURL URLWithString:self.message.content[@"contentVideo"]];
        self.resizeCallback(videoSize, url, self.reload);
        [self resizeViewConstraints:self.contentVideo contentUrl: url];
    }
}


#pragma mark Resizing Methods

-(void) resizeViewConstraints: (UIView*)view contentUrl:(NSURL*)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSCache * contentSizeCache = [MCEInboxPostTemplate sharedInstance].contentSizeCache;
        CGFloat width = self.container.frame.size.width;
        CGFloat height = 0;
        NSString * contentSizeString = [contentSizeCache objectForKey: url];
        if(contentSizeString)
        {
            self.reload = FALSE;
            CGSize cachedContentSize = CGSizeFromString(contentSizeString);
            if(cachedContentSize.height > 0 && cachedContentSize.width > 0)
            {
                if(width < cachedContentSize.width) {
                    height = (cachedContentSize.height/cachedContentSize.width) * width;
                } else {
                    height = cachedContentSize.height;
                }
            }
        }
        self.contentConstraint.constant = height;
    });
}

-(void)resizeViewConstraints: (UIView*)view size:(CGSize)size
{
    for (NSLayoutConstraint * constraint in view.constraints)
    {
        if(constraint.firstAttribute == NSLayoutAttributeWidth)
        {
            constraint.constant = size.width;
        }
        else if(constraint.firstAttribute == NSLayoutAttributeHeight)
        {
            constraint.constant = size.height;
        }
    }
}

@end
