- (void) handleWatchDynamicNotificationPayload:(NSDictionary *) notificationPayload{
    NSLog(@"watch start %@", notificationPayload);
    NSDictionary *watchPayload = notificationPayload[@"watch-dynamic"];
    if(!watchPayload){
        return;
    }
    NSLog(@"watch payload %@", watchPayload);
    
    NSDictionary * title = watchPayload[@"title"];
    if(title)
    {
        NSLog(@"Watch setting title");
        self.label.hidden=NO;
        if(title[@"text"])
            self.label.text = title[@"text"];
        if(title[@"color"])
            self.label.textColor = [self colorWithHexString: title[@"color"]];
        NSLog(@"Watch set title");
    }

    NSDictionary * body = watchPayload[@"body"];
    if(body)
    {
        NSLog(@"Watch setting body");
        self.body.hidden=NO;
        if(body[@"text"])
            self.label.text = body[@"text"];
        if(body[@"color"])
            self.label.textColor = [self colorWithHexString: body[@"color"]];
        NSLog(@"Watch set body");
    }

    NSDictionary * header = watchPayload[@"header"];
    if(header)
    {
        NSLog(@"Watch setting header");
        self.header.hidden=NO;
        [self downloadImageWithURL:[self retrieveImageURL:header] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded)
                self.header.image=image;
        }];
        NSLog(@"Watch set header");
    }

    NSDictionary * background = watchPayload[@"background"];
    if(background)
    {
        NSLog(@"Watch setting background");
        self.group.hidden=NO;
        [self downloadImageWithURL:[self retrieveImageURL:background] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded)
                self.group.backgroundImage=image;
        }];
        NSLog(@"Watch set background");
    }


    NSDictionary * map = watchPayload[@"map"];
    if(map)
    {
        NSLog(@"Watch setting map");
        self.map.hidden=NO;
        if(map[@"lat"] && map[@"long"]){
            double latitude = [map[@"lat"] doubleValue];
            double longitude = [map[@"long"] doubleValue];
            [self.map setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude), 800, 800)];
            [self.map addAnnotation:CLLocationCoordinate2DMake(latitude, longitude) withPinColor:WKInterfaceMapPinColorRed];
        }
        NSLog(@"Watch set map");
    }
}

-(void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
    [self handleWatchDynamicNotificationPayload:localNotification.userInfo];
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    [self handleWatchDynamicNotificationPayload:remoteNotification];
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}


- (NSURL*) retrieveImageURL:(NSDictionary *) payload {
    CGRect screenBounds =  [WKInterfaceDevice currentDevice].screenBounds;
    NSString *urlString;
    if(screenBounds.size.height == 170 && screenBounds.size.width == 136 )
        urlString = payload[@"src-38"];
    else
        urlString  = payload[@"src-42"];
    
    
    // If the user didn't specfiy any specfic image
    if(!urlString)
        urlString  = payload[@"src"];
    
    return [NSURL URLWithString: urlString];
}

#pragma Utility

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if ( !error )
        {
            UIImage *image = [[UIImage alloc] initWithData:data];
            completionBlock(YES,image);
        } else{
            completionBlock(NO,nil);
        }
    }] resume];
}


-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
