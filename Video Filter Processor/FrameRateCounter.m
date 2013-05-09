//
//  FrameRateCounter.m
//  Video Filter Processor
//
//  Created by Franzi on 08.04.13.
//
//

#import "FrameRateCounter.h"

@implementation FrameRateCounter
@synthesize frameRate, frames;

- (id)init
{
    self = [super init];
    if (self) {
        self.frameRate = 0;
        self.frames = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(countNewFrame:)
                                                     name:@"NewFrameProcessed"
                                                   object:nil];
    }
    return self;
}

-(void)countNewFrame:(NSNotification *)notification{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        int _frames = self.frames + 1;
        
        dispatch_time_t now = dispatch_time(DISPATCH_TIME_NOW, 0);
        
        if (now - self.lastFrameRateUpdateTimestamp > NSEC_PER_SEC) {
            [self updateFramerate: _frames];
            self.frames = 0;
        }else{
            self.frames = _frames;
        }
    });
    
}

-(void)updateFramerate:(int)numberOfFrames{
    dispatch_time_t now = dispatch_time(DISPATCH_TIME_NOW, 0);
    dispatch_time_t elapsedTime = (now - self.lastFrameRateUpdateTimestamp) / NSEC_PER_SEC;
    
    self.frameRate = numberOfFrames / elapsedTime; // change will be noticed via key-value-observing of the property
    
    self.lastFrameRateUpdateTimestamp = now;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NewFrameProcessed"
                                                  object:nil];
    [super dealloc];
}

@end
