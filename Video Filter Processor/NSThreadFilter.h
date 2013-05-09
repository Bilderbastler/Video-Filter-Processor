//
//  NSThreadFilter.h
//  Video Filter Processor
//
//  Created by Franzi on 11.11.12.
//
//

#import "AbsVideoFilter.h"



@interface NSThreadFilter : AbsVideoFilter{
    NSMutableArray* _threads;
    NSNumber* _numberOfThreads;
    NSCondition* workerLock;
    NSCondition* producerLock;
    // nummber of workitems that where not claimed by threats yet
    volatile int workItems;
    // number of workitems that where not yet finished
    volatile int unfinishedWorkItems;
}
@property(nonatomic, retain) NSNumber* numberOfThreads;

-(void)workerThreadStartPoint;
@end
