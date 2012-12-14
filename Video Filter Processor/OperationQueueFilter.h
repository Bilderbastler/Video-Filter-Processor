//
//  OperationQueueFilter.h
//  Video Filter Processor
//
//  Created by Franzi on 23.11.12.
//
//

#import "AbsVideoFilter.h"

@interface OperationQueueFilter : AbsVideoFilter{
    NSMutableArray* _operations;
    NSOperationQueue* _queue;
}
@property(atomic) NSUInteger numberOfOperations;
@property NSUInteger concurrentOperationsCount;
@end
