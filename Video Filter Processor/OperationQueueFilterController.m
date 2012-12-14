//
//  OperationQueueFilterController.m
//  Video Filter Processor
//
//  Created by Franzi on 24.11.12.
//
//

#import "OperationQueueFilterController.h"
#import "OperationQueueFilter.h"

@interface OperationQueueFilterController ()

@end

@implementation OperationQueueFilterController
@synthesize maxConcurrentOperations, tasksPerFrame;
-(id)initWithWindowNibName:(NSString *)windowNibName filter:(AbsVideoFilter *)filter{
    self = [super initWithWindowNibName:windowNibName filter:filter];
    if (self) {
         OperationQueueFilter* opFilter = (OperationQueueFilter*) filter;
        self.maxConcurrentOperations = 100;
        self.tasksPerFrame = opFilter.numberOfOperations;
        [self addObserver:self forKeyPath:@"maxConcurrentOperations" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"tasksPerFrame" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
    
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"maxConcurrentOperations"];
    [super dealloc];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    OperationQueueFilter* filter = (OperationQueueFilter*) _filter;
    if ([keyPath isEqualToString:@"maxConcurrentOperations"]) {
        filter.concurrentOperationsCount = [[change valueForKey:@"new"] intValue] ;
    }else if ([keyPath isEqualToString:@"tasksPerFrame"]){
        filter.numberOfOperations = [[change valueForKey:@"new"] intValue];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.ParallelCountStepper.intValue = self.maxConcurrentOperations;
    [self.ParallelCountStepper setEnabled:NO];
    self.parallelCountTextField.intValue = self.maxConcurrentOperations;
    
    self.taskPerFrameStepper.intValue = self.tasksPerFrame;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)automaticParallelExecution:(NSButton *)sender {
    OperationQueueFilter* filter = (OperationQueueFilter*) _filter;
    if (sender.state == 1) {
        [self.ParallelCountStepper setEnabled:NO];
        [self.parallelCountTextField setEnabled:YES];
        filter.concurrentOperationsCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    } else {
        [self.ParallelCountStepper setEnabled:YES];
        [self.parallelCountTextField setEnabled:YES];
        filter.concurrentOperationsCount = self.maxConcurrentOperations;
    }
}
@end
