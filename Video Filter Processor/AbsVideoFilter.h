//
//  AbsVideoFilter.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/** name of the notification that is emited when ever a new filter is
  created */
extern NSString * const NEW_FILTER_NOTIFICATION;

/** container struct for RGB Values */
struct RGBData {
    double r;
    double g;
    double b;
};
/* Base Class for the different Filter Algorithms */
@interface AbsVideoFilter : NSObject{
    size_t bufferHeight;
    size_t bufferWidth;
    size_t bytesPerRow;
    size_t bytesPerPixel;
    unsigned char *base;
    CVPixelBufferRef _buffer;
}
/** values for shadow-regions of the image */
@property struct RGBData blacks;
/** values for grey regions of the image */
@property struct RGBData mids;
/** values for the brighter regions of the image */
@property struct RGBData highlights;

/** called from the Player Model to start the processing on the buffer for 
 the current frame. Calls runAlgorithm to start the implementation of the algorithm*/
- (CVPixelBufferRef)processBuffer:(CVPixelBufferRef)buffer;

/** the way the color correction algorithm is called 
 needs to be overriden by every sub-class with its version of 
 the algorithm */
-(void)runAlgorithm;
/*
 the acutal algorithm that calculates the corrections for one pixel
 - not used for calculations on the gpu of course -
 */
-(unsigned char)calculateCorrectionForChannel:(unsigned char)oldValue lift:(float)offset gamma:(float)power gain:(float)slope;
@end
