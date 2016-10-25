/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2015
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@class MCEInAppMessage;

/** The MCEInAppTemplate protocol specifies the required methods for templates to register with the MCEInAppTemplateRegistry. */
@protocol MCEInAppTemplate <NSObject>

/** The displayInAppMessage: method configures your view controller to display the specified message and present the message to the user. */
-(void) displayInAppMessage:(MCEInAppMessage*)message;

/** The registerTemplate method registers this template with the MCEInAppTemplateRegistry. */
+(void) registerTemplate;

@end

