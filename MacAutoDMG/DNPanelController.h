//
//  DNPanelController.h
//  TestPanel
//
//  Created by Xu Jun on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DNPanelController : NSObject {
    IBOutlet NSPanel *panel;
    IBOutlet NSTextField *textField;
}

- (IBAction)onEndSheet:(id)sender;

- (void)showPanel:(NSWindow*)attachWindow;

@end
