//
//  NSThreadFilter.m
//  Video Filter Processor
//
//  Created by Franzi on 11.11.12.
//
//

#import "NSThreadFilter.h"


@implementation NSThreadFilter

- (id)init
{
    self = [super init];
    if (self) {
        _numberOfThreads = @1;
        _threads = [[NSMutableArray alloc] init];
        workerLock = [[NSCondition alloc] init];
        producerLock = [[NSCondition alloc] init];
        
    }
    return self;
}

-(void)setNumberOfThreads:(NSNumber *)threadNumber{
    @synchronized(_numberOfThreads){
        NSNumber* newValue = [[NSNumber numberWithInt:[threadNumber intValue]]retain];
        [_numberOfThreads release];
        
        if([threadNumber intValue] < 1){
            [newValue release];
            newValue = [@1 retain];
        }
        [self willChangeValueForKey:@"numberOfThreads"];
        _numberOfThreads = newValue;
        [self didChangeValueForKey:@"numberOfThreads"];
    }
}

-(NSNumber *)numberOfThreads{
    return [_numberOfThreads autorelease];
}

/* public start point for the processing of an image */
-(void)runAlgorithm{
    [workerLock lock];
    
    [self updateAmoutOfThreads];
    // set workitem amount 
    unfinishedWorkItems = (unsigned int) [_threads count];
    workItems = (unsigned int)[_threads count];
    
    // send  signals to all worker threats, so that every threat wakes up
    [workerLock broadcast];

    [workerLock unlock];
    
    // wait for the finished image
    [producerLock lock];
    while (unfinishedWorkItems > 0) {
        [producerLock wait];
    }
    [producerLock unlock];
}
/* 
 create or remove threads according to the numberOfThreads property 
 */
-(void)updateAmoutOfThreads{
    @synchronized(_numberOfThreads){
        NSThread* t;
        // add more threads if nessesary
        while ([_threads count] < [self.numberOfThreads intValue]) {
            t = [[[NSThread alloc]initWithTarget:self selector:@selector(workerThreadStartPoint) object:nil] autorelease];
            NSString* n = [NSString stringWithFormat:@"Workerthread %li", [_threads count]];
            [t setName: n];
            [t start];
            [_threads addObject:t];
            
        }
        // or remove threads if nessesary
        while ([_threads count] > [self.numberOfThreads intValue]) {
            t = (NSThread*) [_threads lastObject];
            [t cancel];
            [_threads removeLastObject];
        }
    }
}

/* entry point fo all the worker threads */
-(void)workerThreadStartPoint{
    while (1) {
        // wait for work
        [workerLock lock];
        [producerLock lock];
        if (unfinishedWorkItems == 0) {
            [producerLock signal];
        }
        [producerLock unlock];
        while (workItems <= 0) {
            [workerLock wait];
        }
        // calculate start and end of the block that we want to work on
        NSUInteger rows = ceil(bufferHeight / [_threads count]);
        NSUInteger rowStart = (workItems - 1) * rows;
        NSUInteger rowEnd = rowStart + rows;
        // make sure we don't go over the legal maximum
        rowEnd = rowEnd > bufferHeight ? bufferHeight : rowEnd;
        
        workItems--;
        //OSAtomicDecrement32Barrier(&workItems);
        [workerLock unlock];
        for (size_t row = rowStart; row < rowEnd; ++row) {
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
        OSAtomicDecrement32Barrier(&unfinishedWorkItems);
        //unfinishedWorkItems--;
    }
}

-(void)dealloc{
    // terminate all threads
    [_threads makeObjectsPerformSelector:@selector(cancel)];
    
    [_threads dealloc];
    [_numberOfThreads dealloc];
    [workerLock dealloc];
    [producerLock dealloc];
    [super dealloc];
    
}
@end
