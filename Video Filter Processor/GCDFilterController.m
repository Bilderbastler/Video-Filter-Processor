//
//  GCDFilterController.m
//  Video Filter Processor
//
//  Created by Franzi on 16.11.12.
//
//

#import "GCDFilterController.h"
#import "GCDFilter.h"

@implementation GCDFilterController
@synthesize tasks;

-(id)initWithWindowNibName:(NSString *)windowNibName filter:(AbsVideoFilter *)filter{
    self = [super initWithWindowNibName:windowNibName filter:filter];
    if (self) {
        GCDFilter *gcdFilter = (GCDFilter*) filter;
        self.tasks = ceil(gcdFilter.lines / gcdFilter.linesPerTask) ;
        [self addObserver:self forKeyPath:@"tasks" options:NSKeyValueObservingOptionNew context:nil];
        [gcdFilter addObserver:self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew context:nil];

    }
    
    return self;
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // tell filter to use the new number of threats from the ui
    if ([keyPath isEqualToString:@"tasks"]) {
        GCDFilter *gcdFilter = (GCDFilter*) self.videoFilter;
        gcdFilter.linesPerTask = ceil(gcdFilter.lines / self.tasks);
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    GCDFilter* gcdFilter = (GCDFilter*) _filter;
    [self.slider setMaxValue:gcdFilter.lines];
    float tasksCount = (gcdFilter.lines / gcdFilter.linesPerTask);
    [self.slider setFloatValue: tasksCount];
    [self.tasksField setStringValue:[NSString stringWithFormat:@"%f", tasksCount]];
}

- (IBAction)priorityRadioGroup:(NSMatrix *)sender {
    GCDFilter * filter = (GCDFilter*) _filter;
    NSInteger tag = [[sender selectedCell] tag];
    switch (tag) {
        case 0:
            filter.queuePriority = DISPATCH_QUEUE_PRIORITY_HIGH;
            break;
        case 1:
            filter.queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
            break;
        case 2:
            filter.queuePriority = DISPATCH_QUEUE_PRIORITY_LOW;
            break;
        case 3:
            filter.queuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
            break;
        default:
            break;
    }
}
- (IBAction)changeDispatchMethod:(NSButtonCell *)sender {
    GCDFilter * filter = (GCDFilter*) _filter;
    NSInteger tag = [[sender selectedCell] tag];
    switch (tag) {
        case 0:
            filter.dispatchMethod = dispatchMethodGroup;
            break;
        case 1:
            filter.dispatchMethod = dispatchMethodApply;
            break;
        default:
            break;
    }
}
@end
