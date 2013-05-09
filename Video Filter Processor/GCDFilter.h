//
//  GCDFilter.h
//  Video Filter Processor
//
//  Created by Franzi on 16.11.12.
//
//

#import "AbsVideoFilter.h"

enum DispatchMethod {
    dispatchMethodApply = 0,
    dispatchMethodGroup = 1
};

@interface GCDFilter : AbsVideoFilter{
    dispatch_queue_t _queue;
    long _queuePriority;
    unsigned int _linesPerTask;
}

@property unsigned int tasks;
@property long queuePriority;
@property (nonatomic) int dispatchMethod;
@end
