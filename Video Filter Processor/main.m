//
//  main.m
//  Video Filter Processor
//
//  Created by  Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
int main(int argc, char *argv[])
{
    [NSApplication sharedApplication];
    [NSApp setDelegate: [AppDelegate new]];
    return NSApplicationMain(argc, (const char **)argv);
}
