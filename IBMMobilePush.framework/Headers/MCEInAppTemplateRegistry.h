/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import "MCEInAppTemplate.h"

/** The MCEInAppTemplateRegistry class is used to tie inApp template names to display handlers. */
@interface MCEInAppTemplateRegistry : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The registerTemplate:handler: method records a specific object to handle templates of the specified name.
 
 @param templateName An identifier that this template can handle.
 @param handler The template that provides the display objects. Must implement the MCEInAppTemplate protocol.
 @return Returns TRUE if the template was able to register and FALSE otherwise.
 */
-(BOOL) registerTemplate:(NSString*)templateName hander:(id<MCEInAppTemplate>)handler;


/** The handlerForTemplate: method returns the registered handler for the specified template name.
 
 @param templateName An identifier tying a template name to an object that handles it.
 @return Returns the template handler object.
 */
-(id<MCEInAppTemplate>) handlerForTemplate:(NSString*)templateName;
@end
