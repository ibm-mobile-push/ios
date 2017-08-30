/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "ExampleViewController.h"
#import <IBMMobilePush/IBMMobilePush.h>

@implementation ExampleViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil payload:(NSDictionary*)payload
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        NSError * error = nil;
        NSData * data = [NSJSONSerialization dataWithJSONObject: payload options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            NSLog(@"Couldn't encode json");
        }
        else
        {
            self.payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

-(IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{ }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.payload)
    {
        self.payloadLabel.text = self.payload;
    }
}

@end

