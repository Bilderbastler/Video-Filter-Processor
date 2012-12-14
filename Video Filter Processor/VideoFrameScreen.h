//
//  VideoFrameScreen.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
/**
 This Class displays a filtered video frame.
 */
@interface VideoFrameScreen : NSView{
	CIImage *videoFrame;   
    CIContext* ctx;
}
@property (readwrite, retain, nonatomic) CIImage *videoFrame;
-(void)displayFrame:(CIImage *)aframe;
@end
