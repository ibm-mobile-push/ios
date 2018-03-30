/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


@class MCEInAppMessage;

/** The MCEInAppTemplate protocol specifies the required methods for templates to register with the MCEInAppTemplateRegistry. */
@protocol MCEInAppTemplate <NSObject>

/** The displayInAppMessage: method configures your view controller to display the specified message and present the message to the user. */
-(void) displayInAppMessage:(MCEInAppMessage*)message;

/** The registerTemplate method registers this template with the MCEInAppTemplateRegistry. */
+(void) registerTemplate;

@end

