//
//  AbsVideoFilter.m
//  Video Filter Processor
//
//  Created by  Neumeister on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbsVideoFilter.h"



/** Constant for the name of the notification*/
NSString * const NEW_FILTER_NOTIFICATION = @"new filter";
@implementation AbsVideoFilter
@synthesize blacks, mids, highlights, useVector, lines = bufferHeight;

- (id)init {
    self = [super init];
    if (self) {
        
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
        
        vFloat vec = {255.f, 255.f, 255.f, 255.f};
        maxWhite = vec;
        
        self.blacks = lift;
        self.mids = gamma;
        self.highlights = gain;
        
        self.useVector = NO;

    }
    return self;
}

-(void)setBlacks:(struct RGBData)someBlacks{
	        blacks = someBlacks;
            vFloat vec = {0.f, self.blacks.r, self.blacks.g, self.blacks.b};
            vLift = vec;
}

-(struct RGBData)blacks{
    
    return blacks;
}

-(void)setMids:(struct RGBData)someMids{
        mids = someMids;
        vFloat vec = {1.f, 1.f - self.mids.r, 1.f - self.mids.g, 1.f - self.mids.b };
        vGamma = vec;
}

-(struct RGBData)mids{
    return mids;
}

-(void)setHighlights:(struct RGBData)someHighlights{
        highlights = someHighlights;
        vFloat vec = {1.f, 1.f + self.highlights.r, 1.f + self.highlights.g, 1.f + self.highlights.b };
        vGain = vec;
}


-(struct RGBData)highlights{
    return highlights;
}

- (CVPixelBufferRef)processBuffer:(CVPixelBufferRef)buffer{
    _buffer = buffer;
    
    self.lines = CVPixelBufferGetHeight(buffer);
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

-(void)calculateCorrectionForPixel:(unsigned char*)baseAdress{
    if (self.useVector) {
        
        vFloat pixel = {255 , baseAdress[1], baseAdress[2], baseAdress[3]};
        
        //normalize
        pixel = pixel / maxWhite;
        
        // gain and lift
        pixel = pixel * vGain;
        pixel = pixel + vLift;
        
        // clamp value betweet 0 and 1.0;
        /*
        float* pixelPtr = (float*) &pixel;
        pixelPtr[1] = fmaxf(fminf(pixelPtr[1], 1.f), 0.f);
        pixelPtr[2] = fmaxf(fminf(pixelPtr[2], 1.f), 0.f);
        pixelPtr[3] = fmaxf(fminf(pixelPtr[3], 1.f), 0.f);
        */
        
        // gamma
        vFloat absPixel = vfabf(pixel);
        absPixel = vpowf(pixel, vGamma);
        pixel = vcopysignf(absPixel, pixel);
        
        // denormalize
        pixel = pixel * maxWhite;
                
        // write result into memory and clamp values between 0 and 255
        float* pixelPtr = (float*) &pixel;
        for (int i = 1; i < 4; i++) {
            baseAdress[i] = (unsigned char) fminf(UCHAR_MAX, fmaxf(0, pixelPtr[i]));
        }
        /*
        baseAdress[1] = (unsigned char) pixelPtr[1];
        baseAdress[2] = (unsigned char) pixelPtr[2];
        baseAdress[3] = (unsigned char) pixelPtr[3];
        */

        
    }else{
        baseAdress[1] = [self calculateCorrectionForChannel:baseAdress[1] lift:self.blacks.r gamma:self.mids.r gain:self.highlights.r];
        baseAdress[2] = [self calculateCorrectionForChannel:baseAdress[2] lift:self.blacks.g gamma:self.mids.g gain:self.highlights.g];
        baseAdress[3] = [self calculateCorrectionForChannel:baseAdress[3] lift:self.blacks.b gamma:self.mids.b gain:self.highlights.b];
    }
}

-(unsigned char)calculateCorrectionForChannel:(unsigned char)oldValue lift:(float)lift gamma:(float)gamma gain:(float)gain{
        float value = oldValue;
        value = value / 255.0f;
        value = value * (1.0f + gain);
        value = value + lift;
        
        // clamp value betweet 0 and 1.0;
        //value = (((value) > (1.0f)) ? (1.0f) : (((value) < (0.0f)) ? (0.0f) : (value)));

        // value = fabsf(value);
        // value = value - truncf(value);
        float absValue = fabsf(value);
        absValue = powf(absValue, (1.0f - gamma));
        value = copysignf(absValue, value);
    
        value = value * 255;
    
        value = fminf(UCHAR_MAX, fmaxf(0, value));
    
        oldValue = (unsigned char) value;
        
        //value = powf(value * slope + offset, power);
        return oldValue ;
}


@end
