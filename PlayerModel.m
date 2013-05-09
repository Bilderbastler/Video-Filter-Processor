//
//  PlayerModel.m
//  Video Filter Processor
//
//  Created by  Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerModel.h"
void* newFilterContext;

@interface PlayerModel()
/** private method for setting up the avfoundation components to read the video file */
-(BOOL)setupReader;
-(BOOL)readFrames;

@end
@implementation PlayerModel
@synthesize filter, dimensions, limitPlaybackToFramerate, aborted, currentFramesPerSecond;
- (id)init {
    self = [super init];
    if (self) {
        self.aborted = NO;
        //create a serial queue for the finished frames
        frameQueue = dispatch_queue_create("de.neumeister.videofilterprocessor.framequeue", DISPATCH_QUEUE_SERIAL);
        dispatch_retain(frameQueue);
        limitPlaybackToFramerate = NO;
        [self addObserver:self forKeyPath:@"filter" options:NSKeyValueObservingOptionNew context:newFilterContext];
    }
    return self;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"filter" context:newFilterContext];
    dispatch_release(frameQueue);
    [self reset];
    [super dealloc];
}

-(BOOL)loadAVAsset:(NSURL*)url{
    if(self.filter == nil){
        NSLog(@"Reading aborted! No filter was set");
        return NO;
    }
    
    // create the video asset from a given URL
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
	asset = [AVURLAsset URLAssetWithURL:url options:options];
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObjects:@"tracks", @"duration", nil] completionHandler:^{
        // /TODOtest for successful load of the values
        NSError *error = nil;
        AVKeyValueStatus status;
        status = [asset statusOfValueForKey:@"tracks" error:&error];
        status = [asset statusOfValueForKey:@"duration" error:&error];       
    }];
    BOOL success = [self setupReader];
    return success;
}

-(BOOL)setupReader{
    // setup the avassetReader
    BOOL success = NO;
    NSError *error = nil;
    reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (reader != nil) {
        NSArray *videotracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if([videotracks count] > 0){
            AVAssetTrack *videoTrack = [videotracks objectAtIndex:0];
            frameRate = [videoTrack nominalFrameRate];
            NSLog(@"Framerate is %f", frameRate);
            dimensions = [videoTrack naturalSize];
            
            if (videoTrack) {
                NSDictionary *decompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB],
                                                       kCVPixelBufferPixelFormatTypeKey,
                                                       [NSDictionary dictionary], (id) kCVPixelBufferIOSurfacePropertiesKey, 
                                                       nil];
                output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                            		outputSettings:decompressionSettings];
                [reader addOutput:output];
                
                success = YES;
               
            }
        }
        
    }
    return success;
}

-(void)startPlayer{
    if(reader){
        /* start the reading of the frames on a seperate queue,
         so that we can start and stop reading more frames without
         interupting the run loop on the main thread
         */
        [self readFrames];   
    }
}

-(BOOL)readFrames{
    // start the avassetReader
    __block BOOL finished = NO;
    BOOL success = [reader startReading];
    if (success) {
        
        __block int frameNr = 0;
        
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
        popTime = startTime;
        
        __block double delayInSeconds = 0.0;
        
        while (!finished && !aborted) {  
            delayInSeconds += 1.0/frameRate;
            
            dispatch_time_t oldFrameTimestamp = popTime;
            //popTime = dispatch_time(startTime, delayInSeconds * NSEC_PER_SEC);
            popTime = dispatch_time(DISPATCH_TIME_NOW, 0);
            self.currentFramesPerSecond = NSEC_PER_SEC / (popTime - oldFrameTimestamp);
            
            if (limitPlaybackToFramerate) {
                [NSThread sleepForTimeInterval:(1.0 / frameRate)];
                
            }
            dispatch_sync(frameQueue, ^{
                // we are no longer within the run loop so we need our own release pool
                @autoreleasepool {
                    frameNr++;
                    // process the frame
                    __block CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
                    if (sampleBuffer != NULL) {
                        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                        if (imageBuffer && (CFGetTypeID(imageBuffer) == CVPixelBufferGetTypeID())) {
                            CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)imageBuffer;
                            CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                            
                            // the magic happens here:
                            pixelBuffer = [self.filter processBuffer:pixelBuffer];
                            
                            CIImage *frame = [CIImage imageWithCVImageBuffer:imageBuffer];
                            
                            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                            
                            // now we are on the main thread so we can safely interact with the GUI
                            dispatch_sync(dispatch_get_main_queue(), ^(void){
                                //tell the world there is a new frame around
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFrameProcessed" object:frame];
                            });
                            //clean up
                            CFRelease(sampleBuffer);
                            sampleBuffer = NULL;
                        }
                        
                    }else{
                        finished = YES;
                        NSLog(@"%@", [[reader error]description]);
                    }
                } // drain autorelease pool
            }); // end dispatch block
        } // end while
    } // end if
    return finished && success;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == newFilterContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FILTER_NOTIFICATION object:self.filter];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)reset{
    [output release];
	[reader release];
    [asset release];
    [filter release];
}

@end
