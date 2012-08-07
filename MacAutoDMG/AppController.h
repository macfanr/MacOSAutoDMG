//
//  AppController.h
//  MacAutoDMG
//
//  Created by Xu Jun on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DNPanelController;

@interface AppController : NSObject {
    IBOutlet id                     tableView;
    IBOutlet NSTextField            *outputField;
    IBOutlet NSTextField            *processingInfo;
    
    IBOutlet NSProgressIndicator    *indicatior;
    IBOutlet NSButton               *browse;
    IBOutlet NSButton               *add;
    IBOutlet NSButton               *remove;
    IBOutlet NSButton               *start;
    IBOutlet NSButton               *mbreak;
    IBOutlet NSWindow               *mainWindow;
    
    IBOutlet NSButton               *codeSignState;
    IBOutlet NSTextField            *codeSignID;
    
    IBOutlet DNPanelController      *aboutController;
    
    NSMutableArray                *appContainer;
    NSArray                       *filetypes;
    BOOL                           isFirstAddedFile;
    BOOL                           isForceStop;
}

@property (nonatomic, retain) NSMutableArray *appContainer;
@property (nonatomic, retain) NSArray *filetypes;

- (IBAction)startAutoPackge:(id)sender;

- (IBAction)stopPackge:(id)sender;

- (IBAction)addApplicationFiles:(id)sender;

- (IBAction)removeSelectedApplication:(id)sender;

- (IBAction)browseFolder:(id)sender;

- (IBAction)aboutMe:(id)sender;

- (void)StopProcessIndicator;

- (void)onApplicationDidFinishLaunching:(NSNotification *)notification;
- (void)onApplicationWillTerminate:(NSNotification *)notification;

@end
