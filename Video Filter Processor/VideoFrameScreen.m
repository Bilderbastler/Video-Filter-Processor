//
//  VideoFrameScreen.m
//  Video Filter Processor
//
//  Created by  Neumeister on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoFrameScreen.h"

@implementation VideoFrameScreen
@synthesize videoFrame;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext]graphicsPort]
                                      options:nil];
        [ctx retain];
    }
    
    return self;
}

-(void)displayFrame:(CIImage *)aframe{
    [aframe retain];
    [videoFrame release];
    videoFrame = aframe;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    //show the frame
    if (videoFrame) {
        
        [videoFrame drawInRect:[self bounds] fromRect:[videoFrame extent] operation:NSCompositeSourceOver fraction:1.0];
    }
}
- (void)dealloc {
    if(videoFrame){
        [videoFrame release];
    }
    [ctx release];
    
    [super dealloc];
}

@end
