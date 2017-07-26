/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#import "MainVC.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface MainVC ()
@property (nonatomic, strong) id previewingContext;
@end

@implementation MainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [version setText: MCESdk.sharedInstance.sdkVersion];
    
    if ([self isForceTouchAvailable]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (BOOL)isForceTouchAvailable
{
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return NO;
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:cellPostion];
    
    if (path) {
        UITableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:path];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        if(tableCell.restorationIdentifier)
        {
            UIViewController *previewController = [storyboard instantiateViewControllerWithIdentifier: tableCell.restorationIdentifier];
            if(previewController)
            {
                previewingContext.sourceRect = [self.view convertRect:tableCell.frame fromView:self.tableView];
                return previewController;
            }
        }
    }
    return nil;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:TRUE];
}

@end
