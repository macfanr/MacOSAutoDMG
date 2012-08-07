//
//  DNPanelController.m
//  TestPanel
//
//  Created by Xu Jun on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DNPanelController.h"


@implementation DNPanelController

- (IBAction)onEndSheet:(id)sender {
    [NSApp endSheet: panel]; //By calling this The didEndSelector will be invoked
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    [panel orderOut: self]; //hide sheet with animation
    [NSApp abortModal];
}

- (void)showPanel:(NSWindow*)attachWindow {   
    [NSApp beginSheet: panel
       modalForWindow: attachWindow
        modalDelegate: self
       didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
    [NSApp runModalForWindow: panel];
}

@end
