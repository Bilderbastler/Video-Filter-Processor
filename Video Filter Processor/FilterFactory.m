//
//  FilterFactory.m
//  Video Filter Processor
//
//  Created by  Neumeister on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterFactory.h"
#import "AbsVideoFilter.h"
#import "SingleThreadFilterController.h"
#import "SingleThreadedFilter.h"
#import "VideoFilterController.h"
#import "NSThreadFilter.h"
#import "NSThreadFilterController.h"
#import "GCDFilter.h"
#import "GCDFilterController.h"
#import "OperationQueueFilter.h"
#import "OperationQueueFilterController.h"
#import "OpenCLFilter.h"
#import "OpenCLFilterController.h"

@implementation FilterFactory

-(VideoFilterController*)filterWithName:(VideoFilterValue)filtername{
   
    // TODO Implementierung der Erzeugung aller Filter klassen
	if (filtername == FilterSingleThread) {
        SingleThreadedFilter* filter = [[SingleThreadedFilter alloc]init ];
        SingleThreadFilterController* controller = [[[SingleThreadFilterController alloc] initWithWindowNibName:@"SingleThreadFilterController" filter:filter]autorelease];
        [filter release];
        return controller;
    }else if (filtername == FilterNSThread) {
        NSThreadFilter* filter = [[NSThreadFilter alloc]init];
        NSThreadFilterController* controller = [[[NSThreadFilterController alloc] initWithWindowNibName:@"NSThreadFilterController" filter:filter]autorelease];
        [filter release];
        return controller;
    }else if (filtername == FilterGCD) {
        GCDFilter* filter = [[GCDFilter alloc]init];
        GCDFilterController* controller = [[[GCDFilterController alloc] initWithWindowNibName:@"GCDFilterController" filter:filter]autorelease];
        [filter release];
        return controller;
    }else if (filtername == FilterOperationQueue) {
        OperationQueueFilter* filter = [[OperationQueueFilter alloc]init];
        OperationQueueFilterController* controller = [[[OperationQueueFilterController alloc]initWithWindowNibName:@"OperationQueueFilterController" filter:filter]autorelease];
        [filter release];
        return controller;
    }else if (filtername == FilterOpenCL) {
        OpenCLFilter* filter = [[OpenCLFilter alloc]init];
        OpenCLFilterController * controlller = [[[OpenCLFilterController alloc]initWithWindowNibName:@"OpenCLFilterController" filter:filter] autorelease];
        [filter release];
        return controlller;
    }else if (filtername == FilterOpenGL) {
        return nil;
    }
    return nil;
}
@end
