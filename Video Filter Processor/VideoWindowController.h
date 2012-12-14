//
//  FilterWindowController.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VideoFrameScreen.h"
#import <AVFoundation/AVFoundation.h>
#define sumOfFrames 10

@interface VideoWindowController : NSWindowController{
    NSMutableArray* lastFramesTimeOffsets;
    IBOutlet VideoFrameScreen *videoScreen;
}
@property (nonatomic, assign) float frameRate;
-(void)showFrame:(NSNotification*)notification;
@end
