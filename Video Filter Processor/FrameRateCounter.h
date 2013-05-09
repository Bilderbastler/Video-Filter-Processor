//
//  FrameRateCounter.h
//  Video Filter Processor
//
//  Created by Franzi on 08.04.13.
//
//

#import <Foundation/Foundation.h>

@interface FrameRateCounter : NSObject
@property (nonatomic) int frames;
@property (nonatomic)float frameRate;
@property (nonatomic) dispatch_time_t lastFrameRateUpdateTimestamp;

-(void)updateFramerate: (int)numberOfFrames;
-(void)countNewFrame:(NSNotification*)notification;
@end
