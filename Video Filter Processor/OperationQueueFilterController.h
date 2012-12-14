//
//  OperationQueueFilterController.h
//  Video Filter Processor
//
//  Created by Franzi on 24.11.12.
//
//

#import "VideoFilterController.h"

@interface OperationQueueFilterController : VideoFilterController
@property (assign) IBOutlet NSTextField *tasksPerFrameTextField;
@property (assign) IBOutlet NSTextField *parallelCountTextField;
@property (assign) IBOutlet NSStepper *ParallelCountStepper;
@property (assign) IBOutlet NSStepper *taskPerFrameStepper;
- (IBAction)automaticParallelExecution:(NSButton *)sender;
@property int maxConcurrentOperations;
@property int tasksPerFrame;
@end
