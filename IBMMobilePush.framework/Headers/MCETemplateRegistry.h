/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
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
