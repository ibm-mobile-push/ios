/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>
#import "MCEInboxPostTemplateVideoPlayerView.h"
#import "MCEInboxPostTemplate.h"

extern const CGSize HEADER_IMAGE_SIZE;
extern const int MARGIN;

@interface MCEInboxPostTemplateView : UIView
@property IBOutlet UILabel * header;
@property IBOutlet UILabel * subHeader;

@property IBOutlet UIActivityIndicatorView * headerActivity;
@property IBOutlet UIImageView * headerImage;

@property IBOutlet UIActivityIndicatorView * contentActivity;
@property IBOutlet UIButton * contentImage;

@property IBOutlet UILabel * contentText;
@property IBOutlet UIView * container;

@property IBOutlet UIStackView * buttonView;
@property IBOutlet UIButton * leftButton;
@property IBOutlet UIButton * rightButton;
@property IBOutlet UIButton * centerButton;

@property IBOutlet MCEInboxPostTemplateVideoPlayerView * contentVideo;
@property IBOutlet UIActivityIndicatorView * videoActivity;
@property IBOutlet UIImageView * videoPlay;
@property IBOutlet UIView * videoCover;
@property IBOutlet UIProgressView * videoProgress;

@property IBOutlet UIView * contentImageView;
@property IBOutlet UIView * contentVideoView;
@property IBOutlet NSLayoutConstraint * contentConstraint;
@property IBOutlet NSLayoutConstraint * actionMargin;
@property IBOutlet NSLayoutConstraint * headerMargin;
@property IBOutlet NSLayoutConstraint * subheaderMargin;

@property BOOL fullScreen;

-(void)prepareForReuse;
-(void)setInboxMessage:(MCEInboxMessage *)inboxMessage resizeCallback:(void (^)(CGSize, NSURL*, BOOL))resizeCallback;

-(IBAction)startVideo:(id)sender;

-(IBAction)leftButton:(id)sender;
-(IBAction)rightButton:(id)sender;
-(IBAction)centerButton:(id)sender;

-(IBAction)enlargeImage:(id)sender;

@end
