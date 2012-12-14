//
//  GCDFilter.m
//  Video Filter Processor
//
//  Created by Franzi on 16.11.12.
//
//

#import "GCDFilter.h"



@implementation GCDFilter
@synthesize linesPerTask;

- (id)init
{
    self = [super init];
    if (self) {
        self.linesPerTask = 100;
        self.queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        self.dispatchMethod = dispatchMethodGroup;
        queue = dispatch_get_global_queue(self.queuePriority, 0);
    }
    return self;
}

-(size_t)lines{
    return bufferHeight;
}

-(void)runAlgorithm{
    [self willChangeValueForKey:@"lines"];
    // well the change actually allready happend in the parent class…
    [self didChangeValueForKey:@"lines"];
    
    // calculate start and end of the block that we want to work on
    NSUInteger rows = self.linesPerTask; // avoid calling linesPerOperation more than onces for unnessesary lock overhead
    int blocks = ceil(bufferHeight / rows);
    
    if (self.dispatchMethod == dispatchMethodGroup) { 
    
        dispatch_group_t group = dispatch_group_create();
        
        // now for the enqeueing process…
        for (int i = 0; i < blocks; i++) {
            
            NSUInteger startRow = i * rows;
            NSUInteger endRow = startRow + rows;
            // make sure we don't go over the legal maximum
            endRow = endRow > bufferHeight ? bufferHeight : endRow;
            
            // enqeue the work
            dispatch_group_async(group, queue, ^(void) {
                for (size_t row = startRow; row < endRow; ++row) {
                    for (size_t column = 0; column < bufferWidth; ++column) {
                        
                        // calculates the adress of the pixel in memory
                        unsigned char *pixel = base + (row * bytesPerRow) + (column * bytesPerPixel);
                        pixel[1] = [self calculateCorrectionForChannel:pixel[1] lift:self.blacks.r gamma:self.mids.r gain:self.highlights.r];
                        pixel[2] = [self calculateCorrectionForChannel:pixel[2] lift:self.blacks.g gamma:self.mids.g gain:self.highlights.g];
                        pixel[3] = [self calculateCorrectionForChannel:pixel[3] lift:self.blacks.b gamma:self.mids.b gain:self.highlights.b];
                    }
                }
            });
        }
        
        // wait for the group to finish all it's tasks. Then we can leave the
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        dispatch_release(group);    
       
    } else if(self.dispatchMethod == dispatchMethodApply){
        dispatch_apply(blocks, queue, ^(size_t idx) {
            NSUInteger startRow = idx * rows;
            NSUInteger endRow = startRow + rows;
            // make sure we don't go over the legal maximum
            endRow = endRow > bufferHeight ? bufferHeight : endRow;
            for (size_t row = startRow; row < endRow; ++row) {
                for (size_t column = 0; column < bufferWidth; ++column) {
                    
                    // calculates the adress of the pixel in memory
                    unsigned char *pixel = base + (row * bytesPerRow) + (column * bytesPerPixel);
                    pixel[1] = [self calculateCorrectionForChannel:pixel[1] lift:self.blacks.r gamma:self.mids.r gain:self.highlights.r];
                    pixel[2] = [self calculateCorrectionForChannel:pixel[2] lift:self.blacks.g gamma:self.mids.g gain:self.highlights.g];
                    pixel[3] = [self calculateCorrectionForChannel:pixel[3] lift:self.blacks.b gamma:self.mids.b gain:self.highlights.b];
                }
            }
        });
    }
    
}

-(void)loopThroughLinesWithIndex:(NSUInteger) idx{
    
}

-(void)setQueuePriority:(long)queuePriority{
    [self willChangeValueForKey:@"queuePriority"];
    _queuePriority = queuePriority;
    queue = dispatch_get_global_queue(queuePriority, 0);
    [self didChangeValueForKey:@"queuePriority"];
    NSLog(@"Priorität geändert");
}

-(long)queuePriority{
    return _queuePriority;
}

@end
