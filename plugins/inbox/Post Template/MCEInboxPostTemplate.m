/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxPostTemplate.h"
#import "MCEInboxPostTemplateCell.h"
#import "MCEInboxPostTemplateDisplay.h"

extern CGFloat UNKNOWN_IMAGE_HEIGHT;

@interface MCEInboxPostTemplate ()
@property UILabel * fakeContentView;
@end

@implementation MCEInboxPostTemplate

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(BOOL)shouldDisplayInboxMessage: (MCEInboxMessage*)inboxMessage
{
    return TRUE;
}

-(instancetype)init
{
    if(self=[super init])
    {
        self.contentSizeCache = [[NSCache alloc] init];
        self.postHeightCache = [[NSCache alloc] init];
        self.fakeContentView = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.fakeContentView setFont:[UIFont systemFontOfSize:17]];
        self.fakeContentView.lineBreakMode = NSLineBreakByWordWrapping;
        [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self.postHeightCache removeAllObjects];
        }];
    }
    return self;
}

/* This method is used to register this template with the template registry system so we can display default template messages */
+(void)registerTemplate
{
    [[MCETemplateRegistry sharedInstance] registerTemplate:@"post" hander:[self sharedInstance]];
}

/* This method will give the inbox system a view controller to display full messages in. */
-(id<MCETemplateDisplay>)displayViewController
{
    return [[MCEInboxPostTemplateDisplay alloc] init];
}

/* This method provides a blank table view cell that can later be customized to preview the message */
-(UITableViewCell *) cellForTableView: (UITableView*)tableView inboxMessage:(MCEInboxMessage *)inboxMessage indexPath:(NSIndexPath*)indexPath
{
    NSString * identifier = @"postTemplateCell";
    MCEInboxPostTemplateCell * cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if(!cell)
    {
        UINib * nib = [UINib nibWithNibName:@"MCEInboxPostTemplateCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier: identifier];
        cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    }
    
    [cell.container setInboxMessage: inboxMessage resizeCallback: ^(CGSize size, NSURL * url, BOOL reload) {
        [self.contentSizeCache setObject:NSStringFromCGSize(size) forKey:url];
        if(reload && [tableView cellForRowAtIndexPath: indexPath])
        {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    return cell;
}

/* This method lets the table view displaying previews know how high cells will be. */
-(float)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath inboxMessage: (MCEInboxMessage*)inboxMessage
{
    NSNumber * cachedHeight = [self.postHeightCache objectForKey: inboxMessage.richContentId];
    if(cachedHeight)
    {
        return [cachedHeight floatValue];
    }
    
    CGFloat width = tableView.frame.size.width - MARGIN * 2;
    CGFloat height = HEADER_IMAGE_SIZE.height + MARGIN * 2;
    
    NSString * videoUrlString = inboxMessage.content[@"contentVideo"];
    NSString * imageUrlString = inboxMessage.content[@"contentImage"];
    NSString * cachedContentSize = nil;
    if(videoUrlString || imageUrlString)
    {
        height += MARGIN;
        
        if(videoUrlString)
        {
            cachedContentSize = [self.contentSizeCache objectForKey: [NSURL URLWithString: videoUrlString]];
        }
        
        if(imageUrlString)
        {
            cachedContentSize = [self.contentSizeCache objectForKey: [NSURL URLWithString: imageUrlString]];
        }
        
        if(cachedContentSize)
        {
            CGSize contentSize = CGSizeFromString(cachedContentSize);
            if(contentSize.height > 0 && contentSize.width > 0)
            {
                height += width * contentSize.height / contentSize.width;
            }
        }
        else
        {
            height += UNKNOWN_IMAGE_HEIGHT;
        }
    }
    
    NSString * contentText = inboxMessage.content[@"contentText"];
    if(contentText)
    {
        height += MARGIN*2;
        
        self.fakeContentView.text = contentText;
        CGRect contentRect = [self.fakeContentView textRectForBounds:CGRectMake(0, 0, width, CGFLOAT_MAX) limitedToNumberOfLines: 2];
        height += contentRect.size.height;
    }
    
    NSArray * actions = inboxMessage.content[@"actions"];
    if(actions)
    {
        height += MARGIN + 30;
    }
    
    if(cachedContentSize)
    {
        [self.postHeightCache setObject: @(height) forKey: inboxMessage.richContentId];
    }
    return height;
}

@end
