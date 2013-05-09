//
//  FilterWindowController.m
//  Video Filter Processor
//
//  Created by  Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoWindowController.h"

static void* fpsContext;

@implementation VideoWindowController
@synthesize frameRate;
-(id)initWithWindowNibName:(NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.frameRate = 0;
        self.fpsCounter = [[[FrameRateCounter alloc]init] autorelease];
        
        [self.fpsCounter addObserver:self forKeyPath:@"frameRate" options:NSKeyValueObservingOptionNew context:fpsContext];
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //Listen for new processed frames to display
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFrame:)
                                                 name:@"NewFrameProcessed"
                                               object:nil];
    
}


-(void)showFrame:(NSNotification*)notification{
    if ([[notification object] isKindOfClass:[CIImage class]]) {
        CIImage* frame = (CIImage*) [notification object];
   		[videoScreen displayFrame:frame];
        
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == fpsContext) {
        // better be sure we are on the main tread before change stuff that influcences the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.frameRate = self.fpsCounter.frameRate;
        });
        
    }
}


- (void)dealloc
{
    [self.fpsCounter removeObserver:self forKeyPath:@"frameRate" context:fpsContext];
    self.fpsCounter = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewFrameProcessed" object:nil];
    [super dealloc];
}

@end
