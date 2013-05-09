//
//  SingleThreadedFilter.m
//  Video Filter Processor
//
//  Created by  Neumeister on 20.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleThreadedFilter.h"


@implementation SingleThreadedFilter

-(void)runAlgorithm{
    for (size_t row = 0; row < bufferHeight; ++row) {
        for (size_t column = 0; column < bufferWidth; ++column) {
            // calculates the adress of the pixel in memory
            // TODO: replace this with the actual algorithm
            unsigned char *pixel = base + (row * bytesPerRow) + (column * bytesPerPixel);
            [self calculateCorrectionForPixel:pixel];
            /*
            pixel[1] = [self calculateCorrectionForChannel:pixel[1] lift:self.blacks.r gamma:self.mids.r gain:self.highlights.r];
            pixel[2] = [self calculateCorrectionForChannel:pixel[2] lift:self.blacks.g gamma:self.mids.g gain:self.highlights.g];
            pixel[3] = [self calculateCorrectionForChannel:pixel[3] lift:self.blacks.b gamma:self.mids.b gain:self.highlights.b];
             */
        }
    }
}


@end
