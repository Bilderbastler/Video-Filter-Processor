//
//  OperationQueueFilter.m
//  Video Filter Processor
//
//  Created by Franzi on 23.11.12.
//
//

#import "OperationQueueFilter.h"

@implementation OperationQueueFilter

- (id)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc]init];
        _operations = [[NSMutableArray alloc]init];
        self.numberOfOperations = 100;
    }
    return self;
}

- (void)dealloc
{
    [_queue release];
    [_operations release];
    [super dealloc];
}

-(NSUInteger)concurrentOperationsCount{
    return _queue.maxConcurrentOperationCount;
}
-(void)setConcurrentOperationsCount:(NSUInteger)concurrentOperationsCount{
    _queue.maxConcurrentOperationCount = concurrentOperationsCount;
    
}

-(void)runAlgorithm{
    [_operations removeAllObjects];
    
    
    int operationsCount = (int) self.numberOfOperations;
    
    int start = 0;
    int linesPerOperation = (int) ceil((float)bufferHeight  / (float)operationsCount);
    int end = linesPerOperation;
    
    for (int i = 0, limit = operationsCount; i < limit; i++) {
        start = linesPerOperation * i;
        end = start + linesPerOperation;
        end = (int) fminf(end, bufferHeight); //end < bufferHeight ? end : (int)bufferHeight;
        
        NSInvocationOperation* op = [[NSInvocationOperation alloc]initWithTarget:self
                                                                        selector:@selector(operationTask:)
                                                                          object:@{@"start" : [NSNumber numberWithInt:start],
                                                                                    @"end" : [NSNumber numberWithInt:end]}];
        
        [_operations addObject:op];
        [op release];

    }
   
    [_queue addOperations:_operations waitUntilFinished:NO];
    [_queue waitUntilAllOperationsAreFinished];

}

-(void)operationTask:(id)data{
    NSDictionary * lines = (NSDictionary*) data;
    size_t start = [(NSNumber*)[lines objectForKey:@"start"] intValue];
    size_t end = [(NSNumber*)[lines objectForKey:@"end"] intValue];
    
    for (size_t row = start; row < end; ++row) {
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
@end
