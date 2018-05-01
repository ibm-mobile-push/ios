/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxPostTemplateCell.h"

#if __has_feature(modules)
@import AVFoundation;
#else
#import <AVFoundation/AVFoundation.h>
#endif

@implementation MCEInboxPostTemplateCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.container prepareForReuse];
}
@end
