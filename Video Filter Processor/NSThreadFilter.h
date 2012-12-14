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
    NSCondition* dispatcherLock;
    // nummber of workitems that where not claimed by threats yet
    NSUInteger workItems;
    // number of workitems that where not yet finished
    NSUInteger unfinishedWorkItems;
}
@property(nonatomic, retain) NSNumber* numberOfThreads;

-(void)workerThreadStartPoint;
@end
