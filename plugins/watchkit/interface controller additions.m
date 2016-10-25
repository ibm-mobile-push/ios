- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification
{
    [self handleActionWithIdentifier: identifier payload: localNotification.userInfo];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification
{
    [self handleActionWithIdentifier: identifier payload: remoteNotification];
}

-(void)handleActionWithIdentifier:(NSString*)identifier payload: (NSDictionary*)payload
{
    int index = [identifier intValue];
    if(payload[@"category-actions"] && [payload[@"category-actions"] isKindOfClass:[NSArray class]] && [payload[@"category-actions"] count] > index)
    {
        NSDictionary * action = payload[@"category-actions"][index];
        NSString * type = action[@"type"];
        [self showOpenInApp];
        [self updateUserActivity:@"com.ibm.handleaction" userInfo:@{@"identifier": identifier, @"payload": payload} webpageURL:nil];
    }
    else
    {
        NSLog(@"There is no action defined for this event. Doing nothing.");
    }
}

-(void)showOpenInApp
{
    WKInterfaceDevice * device = [WKInterfaceDevice currentDevice];
    CGRect screenBounds = [device screenBounds];
    if(screenBounds.size.width==136)
    {
        [self.openLabel setHidden:FALSE];
        [self.openImage setHidden:FALSE];
        [self.openImage setImage:[UIImage imageNamed:@"iphone-38"]];
    }
    else if(screenBounds.size.width==156)
    {
        [self.openLabel setHidden:FALSE];
        [self.openImage setHidden:FALSE];
        [self.openImage setImage:[UIImage imageNamed:@"iphone-42"]];
    }
    else
    {
        [self.openLabel setHidden:FALSE];
        [self.openLabel setText:NSStringFromCGRect(screenBounds)];
    }
}
