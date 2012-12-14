//
//  FilterWindowController.m
//  Video Filter Processor
//
//  Created by Florian Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoWindowController.h"

@implementation VideoWindowController
@synthesize frameRate;
-(id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.frameRate = 0;
        lastFramesTimeOffsets = [[NSMutableArray arrayWithObject:@0] retain];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

-(void)showFrame:(NSNotification*)notification{
    if ([[notification object] isKindOfClass:[CIImage class]]) {
        CIImage* frame = (CIImage*) [notification object];
   		[videoScreen displayFrame:frame];
        
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentFramesPerSecond"]) {
        if ([change valueForKey:@"new"] != [NSNull null]) {
            id newValue = [change valueForKey:@"new"];
            [lastFramesTimeOffsets addObject:newValue];
            
            // update the displayed frame rate with the average of the latest framerate values
            // and only when enough data was collected
            if ([lastFramesTimeOffsets count] > sumOfFrames) {
                NSNumber * sum = [lastFramesTimeOffsets valueForKeyPath:@"@sum.self"];
                [lastFramesTimeOffsets removeAllObjects];
                self.frameRate = [sum floatValue]  / sumOfFrames;
            }
        }
    }
}

- (void)dealloc
{
    [lastFramesTimeOffsets release];
    [super dealloc];
}

@end
