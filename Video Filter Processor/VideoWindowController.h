//
//  FilterWindowController.h
//  Video Filter Processor
//
//  Created by  Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VideoFrameScreen.h"
#import <AVFoundation/AVFoundation.h>
#import "FrameRateCounter.h"

@interface VideoWindowController : NSWindowController{
    IBOutlet VideoFrameScreen *videoScreen;
}
@property (nonatomic, assign) float frameRate;
@property (nonatomic, retain) FrameRateCounter* fpsCounter;
-(void)showFrame:(NSNotification*)notification;
@end
