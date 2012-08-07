//
//  AppDelegate.m
//  MacAutoDMG
//
//  Created by Xu Jun on 7/30/12.
//
//

#import "AppDelegate.h"
#import "AppController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [appController onApplicationDidFinishLaunching:notification];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [appController onApplicationWillTerminate:notification];
}

@end
