//
//  AppController.m
//  MacAutoDMG
//
//  Created by Xu Jun on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "ScriptController.h"
#import "DNPanelController.h"

#define kCodeSignState      @"kCodeSignState"
#define kDeveloperID        @"kDeveloperID"


@implementation AppController
@synthesize appContainer, filetypes;

- (void)onApplicationDidFinishLaunching:(NSNotification *)notification
{
    isForceStop = NO;
    
    [tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [outputField setStringValue:NSHomeDirectory()];
    
    NSArray *_fileTypes = [NSArray arrayWithObjects:@"app", nil];
    [self setFiletypes:_fileTypes];
    
    [self StopProcessIndicator];
    [remove setEnabled:NO];
    isFirstAddedFile = NO;
}

- (void)onApplicationWillTerminate:(NSNotification *)notification
{

}

- (void)StartupProcessIndicator {
    [indicatior setHidden:NO];
    [mbreak setEnabled:YES];
    [indicatior startAnimation:nil];
}

- (void)StopProcessIndicator {
    [indicatior setHidden:YES];
    [mbreak setEnabled:NO];
    [indicatior stopAnimation:nil];
}

- (NSString*)getFinalOutPutDMGName:(NSString*)file withOutPutPath:(NSString*)outpath {
    NSString *filePath = (outpath != nil)?outpath:[file stringByDeletingLastPathComponent];
    NSString *fileName = [file lastPathComponent];
    
    NSMutableString *mfileNameWithoutExt = nil;
    @try {
        if([[[file pathExtension]lowercaseString]isEqualToString:[@"app" lowercaseString]]) {
            NSString *fileNameWithoutExt = [[fileName componentsSeparatedByString:@"."]objectAtIndex:0];
            mfileNameWithoutExt = [[NSMutableString alloc]initWithCapacity:[fileNameWithoutExt length]];
            [mfileNameWithoutExt setString: [fileNameWithoutExt lowercaseString]];
            
            NSRange searchRange0 = {0, [mfileNameWithoutExt length]};
            
            [mfileNameWithoutExt replaceOccurrencesOfString:@" "
                                                 withString:@"-" 
                                                    options:NSCaseInsensitiveSearch
                                                      range:searchRange0];
            
            NSRange searchRange1 = {0, [mfileNameWithoutExt length]};
            [mfileNameWithoutExt replaceOccurrencesOfString:@"---"
                                                 withString:@"-" 
                                                    options:NSCaseInsensitiveSearch
                                                      range:searchRange1];
            
            NSRange searchRange2 = {0, [mfileNameWithoutExt length]};
            [mfileNameWithoutExt replaceOccurrencesOfString:@"--"
                                                 withString:@"-" 
                                                    options:NSCaseInsensitiveSearch
                                                      range:searchRange2];
        }
    }
    @catch (NSException * e) {
        if(mfileNameWithoutExt) 
            [mfileNameWithoutExt release];
        mfileNameWithoutExt = nil;
    }
   
    NSString *rst = nil;
    if(mfileNameWithoutExt)
        rst = [[NSString alloc]initWithFormat:@"%@/%@.dmg", filePath, mfileNameWithoutExt];
    else
        rst = [[NSString alloc]initWithFormat:@"%@/%@.dmg", filePath, fileName]; 
    
    return [rst autorelease];
}

- (void)addApplicationToContainer:(NSString*)app {
    
    if(appContainer == nil) {
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        [self setAppContainer:mArray];
        [mArray release];
    }
    
    if(isFirstAddedFile == NO) {
        [outputField setStringValue:[app stringByDeletingLastPathComponent]];
        isFirstAddedFile = YES;
    }
    [remove setEnabled:YES];
    [appContainer addObject:app];
    [tableView reloadData];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[appContainer count]-1];
    [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)removeApplicationFromContainer:(int)indx {
    
    if(indx >=0 && indx < [appContainer count]) {
        [appContainer removeObjectAtIndex:indx];
        [tableView reloadData];
    }
    if((int)[appContainer count] - 1 >= 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[appContainer count]-1];
        [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    if([appContainer count] == 0) {
        [remove setEnabled:NO];
    }
}

- (void)updateUI:(NSNumber*)tableRow {
    NSInteger row = [tableRow integerValue];
    NSString *file = [appContainer objectAtIndex:row];
    
    [processingInfo setStringValue:file];
    [(NSTableView*)tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)setWidgetState:(BOOL)state {
    [browse setEnabled:state];
    [add setEnabled:state];
    [remove setEnabled:state];
    [start setEnabled:state];
    [outputField setEnabled:state];
}

- (void)beginCreatingProcess {
    isForceStop = NO;
    [self setWidgetState:NO];
    [self StartupProcessIndicator];
}

- (void)endCreatingProcess {
    
    isForceStop = NO;
    [self setWidgetState:YES];
    [self StopProcessIndicator];
    
    [processingInfo setStringValue:@" Done "];
    [[NSWorkspace sharedWorkspace]openFile:[outputField stringValue] withApplication:@"Finder.app"];
}

- (void)onAPPError:(NSNumber*)errorNumber {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Some error happen, retry please!"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    [alert beginSheetModalForWindow:[add window]
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:nil];
    
    [self setWidgetState:YES];
    [self StopProcessIndicator];
    isForceStop = NO;
}

- (BOOL)checkTMPDMGFileName:(NSString*)file {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:file]) return YES;
    return NO;
}

- (void)thread_Create_Package {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *tempDMGNameWithPath = [NSHomeDirectory() stringByAppendingString:@"/tmpdmg.dmg"];
    NSString *backgroundImageNameWithPath = [[NSBundle mainBundle]pathForResource:@"m" ofType:@"jpg"];
    NSString *outputPath = [outputField stringValue];
    NSString *devID = nil;
    
    if([codeSignState state] == NSOnState)
        devID = [[codeSignID stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSAppleEventDescriptor *rst = nil;
    
    [self performSelectorOnMainThread:@selector(beginCreatingProcess) withObject:nil waitUntilDone:NO];
    int i = 1;
    
    while ([self checkTMPDMGFileName:tempDMGNameWithPath]) {
        NSString *iname = [NSString stringWithFormat:@"/tmpdmg%i.dmg", i++];
        tempDMGNameWithPath = [NSHomeDirectory() stringByAppendingString:iname];
        i++;
    }
    
    NSInteger index = 0;
    for(NSString *file in appContainer) {
        if(!isForceStop) {
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:[NSNumber numberWithInteger:index] waitUntilDone:NO];
            NSString *finalDMGNameWithPath = [self getFinalOutPutDMGName:file withOutPutPath:outputPath];
            rst = [ScriptController createPackageWithAppName:file
                                                  tmpDMGName:tempDMGNameWithPath
                                             backgroundImage:backgroundImageNameWithPath
                                                finalDMGName:finalDMGNameWithPath
                                                 developerID:devID];
            if(rst == nil) isForceStop = YES;
        }
        index += 1;
    }
    if(rst) {
        [self performSelectorOnMainThread:@selector(endCreatingProcess) withObject:nil waitUntilDone:NO];
    }
    else {
        [self performSelectorOnMainThread:@selector(onAPPError:) withObject:nil waitUntilDone:NO];
    }
    
    [pool release];
}

- (IBAction)startAutoPackge:(id)sender {
    if([appContainer count] > 0) {
        [NSThread detachNewThreadSelector:@selector(thread_Create_Package)
                                 toTarget:self 
                               withObject:nil];
    }
}

- (IBAction)stopPackge:(id)sender {
    isForceStop = YES;
}

- (IBAction)addApplicationFiles:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    SEL sel = @selector(openApplicationPanelDidEnd:returnCode:contextInfo:);
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel beginSheetForDirectory:@"~/Volumes" 
                                 file:nil 
                                types:filetypes
					   modalForWindow:[NSApp mainWindow]
                        modalDelegate:self 
                       didEndSelector:sel 
                          contextInfo:nil];
}

- (IBAction)removeSelectedApplication:(id)sender {
    
    int indx = [tableView numberOfSelectedRows]-1;
    [self removeApplicationFromContainer:indx];
}

- (IBAction)browseFolder:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    SEL sel = @selector(openFolderDidEnd:returnCode:contextInfo:);
    
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetForDirectory:@"~/"
                                 file:nil
                       modalForWindow:[NSApp mainWindow]
                        modalDelegate:self 
                       didEndSelector:sel
                          contextInfo:nil];
}

- (IBAction)aboutMe:(id)sender {
    [NSBundle loadNibNamed:@"MPanel" owner:self];
    [aboutController showPanel:mainWindow];
}

- (void)openApplicationPanelDidEnd:(NSOpenPanel*)openPanel returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    if(returnCode == NSOKButton) {
        NSArray *files = [openPanel filenames];
        
        for(NSString *file in files) {
            [self addApplicationToContainer:file];
        }
        [tableView reloadData];
    }
}

- (void)openFolderDidEnd:(NSOpenPanel*)openPanel returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    if(returnCode == NSOKButton) {
        NSArray *files = [openPanel filenames];
        [outputField setStringValue:[files lastObject]];
    }
}

#pragma mark NSTableView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tv {

    return [appContainer count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *content = [appContainer objectAtIndex:row];
    return content;
}

- (NSDragOperation) tableView:(NSTableView*)view 
                 validateDrop:(id)info 
                  proposedRow:(int)row
        proposedDropOperation: (NSTableViewDropOperation) op {
    NSDragOperation dragOp = NSDragOperationGeneric;
    [view setDropRow: row dropOperation: op];
    return dragOp;
}

- (BOOL) tableView:(NSTableView *) view
        acceptDrop:(id) info
               row:(int) row
     dropOperation:(NSTableViewDropOperation) op {
    
    BOOL reslt = NO;
    
    if (op == NSTableViewDropOn) {
        // 替换
    } 
    else if (op == NSTableViewDropAbove) {
        // 插入
        NSArray *files = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        //NSURL *fileURL=[NSURL URLFromPasteboard: [info draggingPasteboard]];
		//NSString *filepath = [[NSString alloc]initWithFormat:@"%@", [fileURL path]];
        for(NSString *filepath in files) {
            if([filetypes containsObject:[[filepath pathExtension]lowercaseString]]) {
                [self addApplicationToContainer:filepath];
                reslt = YES;
            }
        }
		//[filepath release];  
    } 
    else {
        NSLog (@"unexpected operation (%d) in %s", op, __FUNCTION__);
    }
    
    return reslt;
    
} 

- (void)dealloc {
    [appContainer release];
    [filetypes release];
    [super dealloc];
}

@end
