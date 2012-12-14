//
//  NSThreadFilterController.m
//  Video Filter Processor
//
//  Created by Franzi on 11.11.12.
//
//

#import "NSThreadFilterController.h"
#import "NSThreadFilter.h"

@implementation NSThreadFilterController
@synthesize threatsNumber;


-(id)initWithWindowNibName:(NSString *)windowNibName filter:(AbsVideoFilter *)filter{
    self = [super initWithWindowNibName:windowNibName filter:filter];
    if (self) {
        NSThreadFilter *threadFilter = (NSThreadFilter*) filter;
        self.threatsNumber = [threadFilter.numberOfThreads floatValue];
        [self addObserver:self forKeyPath:@"threatsNumber" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // tell filter to use the new number of threats from the ui
    if ([keyPath isEqualToString:@"threatsNumber"]) {
        NSThreadFilter *threatFilter = (NSThreadFilter*) self.videoFilter;
        threatFilter.numberOfThreads = [NSNumber numberWithFloat:self.threatsNumber];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
