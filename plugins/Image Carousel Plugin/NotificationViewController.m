/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

/*
Example Payload
{
    "aps": {
        "mutable-content": 1,
        "category": "carousel",
        "alert": {
            "title": "Testing Title",
            "subtitle": "Testing Subtitle",
            "body": "Testing Body"
        },
        "sound": "default"
    },
    "notification-action": {
        "type": "carousel"
    },
    "category-name": "carousel",
    "category-actions": [{
        "type": "next",
        "name": "Next"
    }, {
        "type": "prev",
        "name": "Previous"
    }, {
        "type": "carousel",
        "name": "Open",
        "destructive": false,
        "authentication": true,
        "foreground": true
    }],
    "carousel": {
        "items": [
            {"url": "https://www.ibm.com/blogs/bluemix/wp-content/uploads/2017/10/City-Speed-Card.jpg", "text": "Speed"},
            {"url": "https://www.ibm.com/blogs/bluemix/wp-content/uploads/2017/10/Agriculture-Card.jpg", "text": "Agriculture"},
            {"url": "https://www.ibm.com/blogs/bluemix/wp-content/uploads/2017/10/Containers-Docker-Kubernetes-Card.jpg", "text": "Containers"},
            {"url": "https://www.ibm.com/blogs/bluemix/wp-content/uploads/2017/10/Connected-City-Card.jpg", "text": "Connected"},
            {"url": "https://www.ibm.com/blogs/bluemix/wp-content/uploads/2017/10/Cloud-Laptop-Card.jpg", "text": "Cloud"}
        ]
    }
}
*/

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>
@property SKScene * scene;
@property NSMutableDictionary * imageNodes;
@property NSMutableDictionary * textNodes;
@property NSInteger selected;
@property UNNotificationContent * content;
@property NSArray * items;
@property dispatch_queue_t queue;
@end

const int TEXT_HEIGHT = 40;

@implementation NotificationViewController

-(void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    
    if(!self.content.userInfo || !self.content.userInfo[@"category-actions"]) {
        NSLog(@"Carousel Plugin can't find category-actions");
        return;
    }
    
    NSArray * actions = self.content.userInfo[@"category-actions"];
    if(![actions isKindOfClass:NSArray.class]) {
        NSLog(@"Carousel Plugin category-actions isn't an array");
        return;
    }
    
    NSInteger actionIndex = response.actionIdentifier.integerValue;
    NSDictionary * action = actions[actionIndex];
    if(![action isKindOfClass: NSDictionary.class]) {
        NSLog(@"Carousel Plugin category-action isn't a dictionary");
        return;
    }
    
    NSString * actionType = actions[actionIndex][@"type"];
    
    if([actionType isEqual: @"next"]) {
        NSLog(@"Carousel Plugin next image");
        [self nextImage];
        completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    } else if([actionType isEqual: @"prev"]) {
        NSLog(@"Carousel Plugin previous image");
        [self prevImage];
        completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    } else if([actionType isEqual: @"carousel"]) {
        NSLog(@"Carousel Plugin open app");
        NSUserDefaults * sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.com.ibm.mce"];
        [sharedDefaults setInteger:self.selected forKey:@"MCECarouselSelected"];
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
    } else if([actionType isEqual: @"cancel"]) {
        NSLog(@"Carousel Plugin cancel");
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    } else {
        NSLog(@"Carousel Plugin can't find expected action type");
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }
}

-(void)prevImage {
    dispatch_async(self.queue, ^{
        [self centerToRight];
        self.selected = [self prevIndex:self.selected];
        [self leftToCenter];
        NSInteger prev = [self prevIndex:self.selected];
        [self getImageNode: prev];
    });
}

-(void)nextImage {
    dispatch_async(self.queue, ^{
        [self centerToLeft];
        self.selected = [self nextIndex:self.selected];
        [self rightToCenter];
        NSInteger next = [self nextIndex:self.selected];
        [self getImageNode: next];
    });
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSUserDefaults * sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.com.ibm.mce"];
    [sharedDefaults removeObjectForKey:@"MCECarouselSelected"];

    self.selected = 0;
    self.scene = [SKScene sceneWithSize: self.skView.frame.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.backgroundColor = self.view.backgroundColor;
    self.imageNodes = [NSMutableDictionary dictionary];
    self.textNodes = [NSMutableDictionary dictionary];
    [self.skView presentScene: self.scene];

    self.content = notification.request.content;
    
    self.titleLabel.text = self.content.title;
    self.subtitleLabel.text = self.content.subtitle;
    self.bodyLabel.text = self.content.body;
    
    NSDictionary * userInfo = self.content.userInfo;
    
    if(!userInfo || !userInfo[@"carousel"] || !userInfo[@"carousel"][@"items"]) {
        NSLog(@"Carousel Plugin could not find URLs in payload %@", userInfo);
        return;
    }
    
    self.items = userInfo[@"carousel"][@"items"];
    if(![self.items isKindOfClass: NSArray.class]) {
        NSLog(@"Carousel Plugin found items in payload, but it is not an array %@", self.items);
        return;
    }

    self.queue = dispatch_queue_create("carousel", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(self.queue, ^{
        [self rightToCenter];
        [self getImageNode: [self nextIndex:0]];
        [self getImageNode: [self prevIndex:0]];
    });
}

-(NSInteger)nextIndex: (NSInteger)index {
    if(index + 1 == self.items.count) {
        return 0;
    }
    return index + 1;
}

-(NSInteger)prevIndex: (NSInteger)index {
    if(index - 1 == -1) {
        return self.items.count - 1;
    }
    return index - 1;
}

-(SKLabelNode*)getTextNode: (NSInteger)index {
    NSString * nodeIndex = [NSString stringWithFormat: @"%ld", index];
    SKLabelNode * node = self.textNodes[nodeIndex];
    
    if(!node) {
        NSString * text = self.items[index][@"text"];
        node = [SKLabelNode labelNodeWithText:text];
        node.fontColor = UIColor.blackColor;
        node.fontSize = TEXT_HEIGHT / 2;
        node.alpha = 0;
        self.textNodes[nodeIndex] = node;
        [self.scene addChild:node];
    }
    
    return node;
}

-(SKSpriteNode*)getImageNode: (NSInteger)index {
    NSString * nodeIndex = [NSString stringWithFormat: @"%ld", index];
    SKSpriteNode * node = self.imageNodes[nodeIndex];
    
    if(!node) {
        NSString * urlString = self.items[index][@"url"];
        node = [self loadNode:urlString];
        node.alpha = 0;
        self.imageNodes[nodeIndex] = node;
        [self.scene addChild:node];
    }
    
    return node;
}

-(void)centerToLeft {
    CGRect frame = self.skView.frame;
    SKSpriteNode * imageNode = [self getImageNode: self.selected];
    SKLabelNode * textNode = [self getTextNode: self.selected];
    CGPoint imageLeft = CGPointMake(CGRectGetMidX(frame) * -1, (frame.size.height - TEXT_HEIGHT) / 2 + TEXT_HEIGHT);
    CGPoint textLeft = CGPointMake(CGRectGetMidX(frame) * -1, imageLeft.y - imageNode.size.height/2 - TEXT_HEIGHT/2);
    dispatch_async(dispatch_get_main_queue(), ^{
        [imageNode runAction: [SKAction group:@[[SKAction moveTo:imageLeft duration:0.25], [SKAction fadeOutWithDuration:0.25]]]];
        [textNode runAction: [SKAction group:@[[SKAction moveTo:textLeft duration:0.25], [SKAction fadeOutWithDuration:0.25]]]];
    });
}

-(void)centerToRight {
    CGRect frame = self.skView.frame;
    SKSpriteNode * imageNode = [self getImageNode: self.selected];
    SKLabelNode * textNode = [self getTextNode: self.selected];
    CGPoint imageRight = CGPointMake(CGRectGetMaxX(frame), (frame.size.height - TEXT_HEIGHT) / 2 + TEXT_HEIGHT);
    CGPoint textRight = CGPointMake(CGRectGetMaxX(frame), imageRight.y - imageNode.size.height/2 - TEXT_HEIGHT/2);
    dispatch_async(dispatch_get_main_queue(), ^{
        [imageNode runAction: [SKAction group:@[[SKAction moveTo:imageRight duration:0.25], [SKAction fadeOutWithDuration:0.25]]]];
        [textNode runAction: [SKAction group:@[[SKAction moveTo:textRight duration:0.25], [SKAction fadeOutWithDuration:0.25]]]];
    });
}

-(void)rightToCenter {
    CGRect frame = self.skView.frame;
    SKSpriteNode * imageNode = [self getImageNode: self.selected];
    SKLabelNode * textNode = [self getTextNode: self.selected];
    CGPoint rightImage = CGPointMake(CGRectGetMaxX(frame), (frame.size.height - TEXT_HEIGHT) / 2 + TEXT_HEIGHT);
    CGPoint centerImage = CGPointMake(CGRectGetMidX(frame), (frame.size.height - TEXT_HEIGHT) / 2 + TEXT_HEIGHT);
    CGPoint rightText = CGPointMake(CGRectGetMaxX(frame), rightImage.y - imageNode.size.height/2 - TEXT_HEIGHT/2);
    CGPoint centerText = CGPointMake(CGRectGetMidX(frame), centerImage.y - imageNode.size.height/2 - TEXT_HEIGHT/2);
    imageNode.position = rightImage;
    imageNode.alpha = 0;
    textNode.position = rightText;
    textNode.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityView stopAnimating];
        [imageNode runAction: [SKAction group:@[[SKAction moveTo:centerImage duration:0.25], [SKAction fadeInWithDuration:0.25]]]];
        [textNode runAction: [SKAction group:@[[SKAction moveTo:centerText duration:0.25], [SKAction fadeInWithDuration:0.25]]]];
    });
}

-(void)leftToCenter {
    CGRect frame = self.skView.frame;
    SKSpriteNode * imageNode = [self getImageNode: self.selected];
    SKLabelNode * textNode = [self getTextNode: self.selected];
    CGPoint leftImage = CGPointMake(CGRectGetMidX(frame) * -1, (frame.size.height - TEXT_HEIGHT) / 2 + TEXT_HEIGHT);
    CGPoint centerImage = CGPointMake(CGRectGetMidX(frame), (frame.size.height - TEXT_HEIGHT) / 2 + TEXT_HEIGHT);
    CGPoint leftText = CGPointMake(CGRectGetMidX(frame) * -1, leftImage.y - imageNode.size.height/2 - TEXT_HEIGHT/2);
    CGPoint centerText = CGPointMake(CGRectGetMidX(frame), centerImage.y - imageNode.size.height/2 - TEXT_HEIGHT/2);
    imageNode.position = leftImage;
    imageNode.alpha = 0;
    textNode.position = leftText;
    textNode.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [imageNode runAction: [SKAction group:@[[SKAction moveTo:centerImage duration:0.25], [SKAction fadeInWithDuration:0.25]]]];
        [textNode runAction: [SKAction group:@[[SKAction moveTo:centerText duration:0.25], [SKAction fadeInWithDuration:0.25]]]];
    });
}

-(SKSpriteNode *)loadNode: (NSString *)urlString {
    CGRect frame = self.skView.frame;
    frame.size.height -= TEXT_HEIGHT * 2;

    NSURL * url = [NSURL URLWithString:urlString];
    if(!url) {
        NSLog(@"Carousel Plugin URL found is not valid %@", url);
        return nil;
    }
    
    NSData * data = [NSData dataWithContentsOfURL:url];
    if(!data) {
        NSLog(@"Carousel Plugin could not download URL %@", url);
        return nil;
    }
    
    UIImage * image = [UIImage imageWithData:data];
    if(!image) {
        NSLog(@"Carousel Plugin downloaded URL is not a valid image %@", url);
        return nil;
    }
    
    SKTexture * texture = [SKTexture textureWithImage:image];
    SKSpriteNode * node = [SKSpriteNode spriteNodeWithTexture:texture];
    if(node.size.width > frame.size.width || node.size.height > frame.size.height) {
        if(node.size.width / node.size.height > frame.size.width / frame.size.height ) {
            node.size = CGSizeMake(frame.size.width, node.size.height / node.size.width * frame.size.width);
        } else {
            node.size = CGSizeMake(node.size.width / node.size.height * frame.size.height, frame.size.height);
        }
    }
    
    return node;
}

@end
