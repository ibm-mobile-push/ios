/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCETemplate.h"

/** The MCETemplateRegistry class is used to specify the template names for which a template class can provide previews and full screen displays. */

@interface MCETemplateRegistry : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The registerTemplate:handler: method records a specific object to handle templates of the specified name.
 
 @param templateName An identifier that this template can handle.
 @param handler The template that provides the preview cells and full page display objects. Must implement the MCETemplate protocol.
 @return Returns TRUE if the template can register and FALSE otherwise.
*/
-(BOOL) registerTemplate:(NSString*)templateName hander:(NSObject*)handler;

/** The viewControllerForTemplate: method returns a view controller for the specified template name. This queries the registered template object for the view controller to display the full screen content.
 
 @param templateName An identifier tying a template name to an object that handles it.
 */
-(id<MCETemplateDisplay>) viewControllerForTemplate: (NSString*)templateName;


/** The handlerForTemplate: method returns the registered handler for the specified template name.

 @param templateName An identifier tying a template name to an object that handles it.
 @return Returns the template handler object.
 */
-(id<MCETemplate>) handlerForTemplate: (NSString*)templateName;

@end
