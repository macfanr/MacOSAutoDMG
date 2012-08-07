//
//  ScriptController.h
//  MacAutoDMG
//
//  Created by Xu Jun on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScriptController : NSObject {

}

+ (NSAppleEventDescriptor*)execAppleScript:(NSString*)script;

+ (NSAppleEventDescriptor*)createPackageWithAppName:(NSString*)appNameWithPath 
                                         tmpDMGName:(NSString*)tmpDMGNameWithPath
                                    backgroundImage:(NSString*)bgNameWithPath 
                                       finalDMGName:(NSString*)finalDMGNameWithPath
                                        developerID:(NSString*)devID;

@end
