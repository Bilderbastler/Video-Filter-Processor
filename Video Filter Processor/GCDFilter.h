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
    dispatch_queue_t queue;
    long _queuePriority;
}

@property(atomic, assign)unsigned int linesPerTask;
@property(nonatomic, readonly)size_t lines;
@property long queuePriority;
@property (nonatomic) int dispatchMethod;
@end
