/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInAppMediaTemplate.h"

@interface MCEInAppMediaTemplate ()
@end

@implementation MCEInAppMediaTemplate

-(IBAction)execute: (id)sender;
{
    [self dismiss:self];
    [[MCEInAppManager sharedInstance] disable: self.inAppMessage];
    
    NSDictionary * payload = @{@"mce": [NSMutableDictionary dictionary]};
    if(self.inAppMessage.attribution)
    {
        payload[@"mce"][@"attribution"] = self.inAppMessage.attribution;
    }
    if(self.inAppMessage.mailingId)
    {
        payload[@"mce"][@"mailingId"] = self.inAppMessage.mailingId;
    }
    
    [MCEActionRegistry.sharedInstance performAction:self.inAppMessage.content[@"action"] forPayload:payload source:InAppSource attributes:nil userText:nil];
}

-(void)setTextHeight
{
    CGRect textSize = [self.textLabel.titleLabel textRectForBounds:CGRectMake(0, 0, self.textLabel.frame.size.width, CGFLOAT_MAX) limitedToNumberOfLines: self.textLabel.titleLabel.numberOfLines];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.textHeightConstraint.constant = textSize.size.height;
        self.foreTextHeightConstraint.constant = textSize.size.height;
        [self.containerView layoutIfNeeded];
        [self.foreContainerView layoutIfNeeded];
    }];
}


-(IBAction)expandText:(id)sender
{
    self.autoDismiss = false;
    self.textLabel.titleLabel.numberOfLines = self.textLabel.titleLabel.numberOfLines ? 0 : 2;
    self.foreTextLabel.titleLabel.numberOfLines = self.foreTextLabel.titleLabel.numberOfLines ? 0 : 2;
    [self setTextHeight];
}


-(void)autoDismiss: (id)sender
{
    if(self.autoDismiss)
    {
        [self dismiss:sender];
    }
}

-(IBAction)dismiss: (id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"Dismissed InApp Message");
    }];
}

-(void)displayInAppMessage:(MCEInAppMessage*)message
{
    [self.spinner startAnimating];
    self.autoDismiss = true;
    NSLog(@"Preparing InApp Message");
    self.inAppMessage = message;
    
    if(self.view.superview)
    {
        [self dismiss:self];
        [self performSelector:@selector(displayInAppMessage:) withObject:message afterDelay:0.3];
        return;
    }
    
    [self.titleLabel setTitle:self.inAppMessage.content[@"title"] forState:UIControlStateNormal];
    [self.foreTitleLabel setTitle:self.inAppMessage.content[@"title"] forState:UIControlStateNormal];
    
    [self.textLabel setTitle:self.inAppMessage.content[@"text"] forState:UIControlStateNormal];
    self.textLabel.titleLabel.numberOfLines = 2;
    
    [self.foreTextLabel setTitle:self.inAppMessage.content[@"text"] forState:UIControlStateNormal];
    self.foreTextLabel.titleLabel.numberOfLines = 2;
    
    [self setTextHeight];
    [self showInAppMessage];
}

-(void)showInAppMessage
{
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:self animated:true completion:^{
        NSLog(@"Displaying InApp Message");
    }];
}

-(BOOL)shouldAutorotate
{
    return true;
}

-(BOOL)isBlurAvailable
{
    if(!NSClassFromString(@"UIBlurEffect"))
    {
        return FALSE;
    }
    
    if (UIAccessibilityIsReduceTransparencyEnabled())
    {
        return FALSE;
    }
    
    return true;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.textLabel.titleLabel.numberOfLines = 2;
    self.titleLabel.titleLabel.numberOfLines = 1;
    
    if([self isBlurAvailable])
    {
        // Blur effect
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView * visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.translatesAutoresizingMaskIntoConstraints=NO;
        
        [self.view addSubview:visualEffectView];
        [self setContraintsForView: visualEffectView];
        
        // Vibrancy effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView * vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints=NO;
        [visualEffectView.contentView addSubview:vibrancyEffectView];
        [self setContraintsForView: vibrancyEffectView];
        
        // Move container view to inside vibrancyEffectView contentView
        [self.containerView removeFromSuperview];
        self.containerView.backgroundColor=[UIColor clearColor];
        [vibrancyEffectView.contentView addSubview:self.containerView];
        [self setContraintsForView: self.containerView];
        
        //* Pull out non vibrant interface and add them to the visualEffectView
        UINib * nib = [UINib nibWithNibName:[NSStringFromClass([self class]) stringByAppendingString: @"Foreground"] bundle:nil];
        NSArray * nibObjects =[nib instantiateWithOwner:nil options:@{}];
        self.foreContainerView = [nibObjects objectAtIndex:0];
        self.foreContainerView.translatesAutoresizingMaskIntoConstraints=NO;
        self.foreContainerView.backgroundColor = [UIColor clearColor];
        
        UIButton * closeButton = [self.foreContainerView viewWithTag:8];
        [closeButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        closeButton.alpha=0.1;
        
        self.foreTitleLabel = [self.foreContainerView viewWithTag:5];
        self.foreTextLabel = [self.foreContainerView viewWithTag:4];
        self.foreTextHeightConstraint = self.foreTextLabel.constraints[0];
        
        self.foreTextLabel.titleLabel.numberOfLines = 2;
        self.foreTitleLabel.titleLabel.numberOfLines = 1;
        
        [visualEffectView.contentView addSubview: self.foreContainerView];
        [self setContraintsForView: self.foreContainerView];
        
        [self.foreTextLabel addTarget:self action:@selector(expandText:) forControlEvents:UIControlEventTouchUpInside];
        [self.foreTitleLabel addTarget:self action:@selector(expandText:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)setContraintsForView:(UIView*)view
{
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:0 metrics:@{} views:@{@"view":view}]];
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:@{} views:@{@"view":view}]];
    
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.queue = dispatch_queue_create("background", nil);
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return true;
}


@end
