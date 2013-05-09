//
//  GCDFilter.m
//  Video Filter Processor
//
//  Created by Franzi on 16.11.12.
//
//

#import "GCDFilter.h"



@implementation GCDFilter
@synthesize tasks;

- (id)init
{
    self = [super init];
    if (self) {
        self.tasks = 10;
        self.lines = 1000; // a default value, so there is no error
        self.queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        self.dispatchMethod = dispatchMethodGroup;
        _queue = dispatch_get_global_queue(self.queuePriority, 0);
    }
    return self;
}


-(void)runAlgorithm{
  
    int blocks = self.tasks;
    NSUInteger rowsInBlock = ceilf((float)bufferHeight / (float)blocks);
    
    if (self.dispatchMethod == dispatchMethodGroup) { 
    
        dispatch_group_t group = dispatch_group_create();
        
        // now for the enqeueing process…
        for (int i = 0; i < blocks; i++) {
            dispatch_group_async(group, _queue, ^(void) {
                [self executeBlock:i linesInBlock:rowsInBlock];
            });
        }
        
        // wait for the group to finish all it's tasks. Then we can leave the
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        dispatch_release(group);    
       
    } else if(self.dispatchMethod == dispatchMethodApply){
        dispatch_apply(blocks, _queue, ^(size_t idx) {
            [self executeBlock:idx linesInBlock:rowsInBlock];
        });
    }
    
}

-(void)executeBlock:(size_t)idx linesInBlock:(size_t)rows{
    NSUInteger startRow = idx * rows;
    NSUInteger endRow = startRow + rows;
    // make sure we don't go over the legal maximum
    endRow = fminf(endRow, bufferHeight);
    for (size_t row = startRow; row < endRow; ++row) {
        for (size_t column = 0; column < bufferWidth; ++column) {
            
            // calculates the adress of the pixel in memory
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

-(void)setQueuePriority:(long)queuePriority{
    [self willChangeValueForKey:@"queuePriority"];
    _queuePriority = queuePriority;
    _queue = dispatch_get_global_queue(queuePriority, 0);
    [self didChangeValueForKey:@"queuePriority"];
    NSLog(@"Priorität geändert");
}

-(long)queuePriority{
    return _queuePriority;
}

@end
