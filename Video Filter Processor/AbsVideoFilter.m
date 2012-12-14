//
//  AbsVideoFilter.m
//  Video Filter Processor
//
//  Created by Florian Neumeister on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbsVideoFilter.h"



/** Constant for the name of the notification*/
NSString * const NEW_FILTER_NOTIFICATION = @"new filter";
@implementation AbsVideoFilter
@synthesize blacks, mids, highlights;

- (id)init {
    self = [super init];
    if (self) {
        // inform the world about a new filter instance
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FILTER_NOTIFICATION object:self];
        struct RGBData lift;
        struct RGBData gamma;
        struct RGBData gain;
        lift.r = 0.0;
        lift.g = 0.0;
        lift.b = 0.0;
        gamma.r = 0.0;
        gamma.g = 0.0;
        gamma.b = 0.0;
        gain.r = 0.0;
        gain.g = 0.0;
        gain.b = 0.0;
        
        self.blacks = lift;
        self.mids = gamma;
        self.highlights = gain;        

    }
    return self;
}

-(void)setBlacks:(struct RGBData)someBlacks{
	        blacks = someBlacks;
}
-(struct RGBData)blacks{
    return blacks;
}
-(void)setMids:(struct RGBData)someMids{
        mids = someMids;
 
}
-(struct RGBData)mids{
    return mids;
}
-(void)setHighlights:(struct RGBData)someHighlights{
          highlights = someHighlights;

}
-(struct RGBData)highlights{
    return highlights;
}

- (CVPixelBufferRef)processBuffer:(CVPixelBufferRef)buffer{
    _buffer = buffer;
    
    bufferHeight = CVPixelBufferGetHeight(buffer);
    bufferWidth = CVPixelBufferGetWidth(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    base = (unsigned char *)CVPixelBufferGetBaseAddress(buffer);
    bytesPerPixel = bytesPerRow / bufferWidth;
    [self runAlgorithm];
    
	return buffer;
}

/*
 This holds the actual implementation of the Algorithm and is supposed to be 
 implemented in the Subclasses
 */
-(void)runAlgorithm{
    return;
}

-(unsigned char)calculateCorrectionForChannel:(unsigned char)oldValue lift:(float)lift gamma:(float)gamma gain:(float)gain{
    float value = oldValue;
    value = value / 255.0f;
    value = value * (1.0f + gain);
    value = value + lift;
    // clamp value betweet 0 and 1.0;
    value = (((value) > (1.0f)) ? (1.0f) : (((value) < (0.0f)) ? (0.0f) : (value)));
    value = powf(value, (1.0f - gamma));
    value = value * 255;
    
    oldValue = (unsigned char) value;
    if(oldValue > 255 || oldValue < 0 ){
        NSLog(@"Pixel im illegalen Bereich!");
    }
    //value = powf(value * slope + offset, power);
    return oldValue ;
}
@end
