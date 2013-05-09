//
//  AppDelegate.m
//  Video Filter Processor
//
//  Created by Franziska Neumeister on 01.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "FilterDocument.h"

@implementation AppDelegate
@synthesize activeItem;
- (id)init
{
    self = [super init];
    if (self) {
        factory = [[FilterFactory alloc] init];
    }
    return self;
}

/*
 - (void)applicationDidFinishLaunching:(NSNotification *)notification{
 }
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{}
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{}
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames{}
- (BOOL)application:(NSApplication *)sender openTempFile:(NSString *)filename{}
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender{}
- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender{}
- (BOOL)application:(id)sender openFileWithoutUI:(NSString *)filename{}
- (BOOL)application:(NSApplication *)sender printFile:(NSString *)filename{}
- (NSApplicationPrintReply)application:(NSApplication *)application printFiles:(NSArray *)fileNames withSettings:(NSDictionary *)printSettings showPrintPanels:(BOOL)showPrintPanels{}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{}
- (NSMenu *)applicationDockMenu:(NSApplication *)sender{}
- (NSError *)application:(NSApplication *)application willPresentError:(NSError *)error{}
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_MAC(10_7){}
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_MAC(10_7){}
- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_MAC(10_7){}
- (void)applicationWillFinishLaunching:(NSNotification *)notification{}
- (void)applicationWillHide:(NSNotification *)notification{}
- (void)applicationDidHide:(NSNotification *)notification{}
- (void)applicationWillUnhide:(NSNotification *)notification{}
- (void)applicationDidUnhide:(NSNotification *)notification{}
- (void)applicationWillBecomeActive:(NSNotification *)notification{}
- (void)applicationDidBecomeActive:(NSNotification *)notification{}
- (void)applicationWillResignActive:(NSNotification *)notification{}
- (void)applicationDidResignActive:(NSNotification *)notification{}
- (void)applicationWillUpdate:(NSNotification *)notification{}
- (void)applicationDidUpdate:(NSNotification *)notification{}
- (void)applicationWillTerminate:(NSNotification *)notification{}
- (void)applicationDidChangeScreenParameters:(NSNotification *)notification{}
*/

- (IBAction)setFilter:(NSMenuItem *)sender {
    [self.activeItem setState:NSOffState];
    self.activeItem = sender;
    [self.activeItem setState:NSOnState];
    NSLog(@"Sender: %ld", sender.tag);
    
    FilterDocument * document = (FilterDocument*)[[NSDocumentController sharedDocumentController]currentDocument];
    VideoFilterController* filter;
    
    switch (sender.tag) {
        case 1:
            filter = [factory filterWithName:FilterNSThread];
            break;
        case 2:
             filter = [factory filterWithName:FilterGCD];
            break;
        case 3:
             filter = [factory filterWithName:FilterOpenCL];
            break;
        case 4:
             filter = [factory filterWithName:FilterOpenGL];
            break;
        case 5:
            filter = [factory filterWithName:FilterOperationQueue];
            break;
        default: // für case 0
            filter = [factory filterWithName:FilterSingleThread];
            break;
    }
    
    [document setFilter:filter];
    
    self.activeItem = sender;
}

- (void)dealloc
{
    [factory release];
    [super dealloc];
}
@end
