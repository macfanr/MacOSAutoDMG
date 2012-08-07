//
//  ScriptController.m
//  MacAutoDMG
//
//  Created by Xu Jun on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define MAPP_NAME_WITH_PATH         @"MM_APP_PATH_NAME"
#define MAPP_NAME                   @"MM_APP_NAME"
#define MBACKGROUND_NAME_WITH_PATH  @"MM_BACK_IMAGE_PATH_NAME"
#define MBACKGROUND_NAM             @"MM_BACK_IMAGE_NAME"
#define MFINAL_DMG_NAME_WITH_PATH   @"MM_FINAL_DMG_PATH_NAME"
#define MTMP_DMG_NAME_WITH_PATH     @"MM_TMP_DMG_PATH_NAME"
#define MDISK_NAME                  @"MM_DISK_NAME"
#define MDEVELOP_ID                 @"MM_DEV_ID"

#import "ScriptController.h"


@implementation ScriptController

+ (NSAppleEventDescriptor*)execAppleScript:(NSString*)script {
    NSDictionary *errorDic = nil;
    NSAppleEventDescriptor *descript = nil;
    NSAppleScript *appScript = [[NSAppleScript alloc]initWithSource:script];
    NSLog(@"%@", script);
    descript = [[appScript executeAndReturnError:&errorDic]retain];
    [appScript release];
    
    return [descript autorelease];
}

+ (NSAppleEventDescriptor*)createPackageWithAppName:(NSString*)appNameWithPath 
                                         tmpDMGName:(NSString*)tmpDMGNameWithPath
                                    backgroundImage:(NSString*)bgNameWithPath 
                                       finalDMGName:(NSString*)finalDMGNameWithPath
                                        developerID:(NSString*)devID {
    //(appNameWithPath, appName, tmpDMGNameWithPath, tmpDiskName, backgroundImageWithPath, backgroundImageName, finalDMGNameWithPath)
    NSString *iAppNameWithPath = appNameWithPath;
        NSString *appNameWithAPP = [appNameWithPath lastPathComponent];
        NSArray *tmpArray = [appNameWithAPP componentsSeparatedByString:@"."];
    NSString *iAppName = [tmpArray objectAtIndex:0];
    NSString *iTmpDMGNameWithPage = tmpDMGNameWithPath;
    NSString *iTmpDiskName = iAppName;
    NSString *iBackgroundImageWithPath = bgNameWithPath;
    NSString *iBackgroundImageName = [bgNameWithPath lastPathComponent];
    NSString *iFinalDMGNameWithPath = finalDMGNameWithPath;
    NSString *iDevID = devID ? devID : @"";
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *scriptPath = [mainBundle pathForResource:@"packge" ofType:@"txt"];
    NSString *script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableString *mutaleScript = [[[NSMutableString alloc]initWithCapacity:[script length]] autorelease];
    
    [mutaleScript setString:script];
    
    //find application path name and replace those charactors
    NSRange range = [mutaleScript rangeOfString:MAPP_NAME_WITH_PATH];
    [mutaleScript replaceCharactersInRange:range withString:iAppNameWithPath];
    
    range = [mutaleScript rangeOfString:MAPP_NAME];
    [mutaleScript replaceCharactersInRange:range withString:iAppName];
    
    range = [mutaleScript rangeOfString:MBACKGROUND_NAME_WITH_PATH];
    [mutaleScript replaceCharactersInRange:range withString:iBackgroundImageWithPath];
    
    range = [mutaleScript rangeOfString:MBACKGROUND_NAM];
    [mutaleScript replaceCharactersInRange:range withString:iBackgroundImageName];
    
    range = [mutaleScript rangeOfString:MFINAL_DMG_NAME_WITH_PATH];
    [mutaleScript replaceCharactersInRange:range withString:iFinalDMGNameWithPath];
    
    range = [mutaleScript rangeOfString:MTMP_DMG_NAME_WITH_PATH];
    [mutaleScript replaceCharactersInRange:range withString:iTmpDMGNameWithPage];
    
    range = [mutaleScript rangeOfString:MDISK_NAME];
    [mutaleScript replaceCharactersInRange:range withString:iTmpDiskName];
    
    range = [mutaleScript rangeOfString:MDEVELOP_ID];
    [mutaleScript replaceCharactersInRange:range withString:iDevID];
    
    return [self execAppleScript:(NSString*)mutaleScript];
}

@end
