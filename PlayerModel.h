//
//  PlayerModel.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AbsVideoFilter.h"


@interface PlayerModel : NSObject{
    /** Blocks for displaying frames are enqeueued here */
    dispatch_queue_t frameQueue;

    float frameRate;
    CGSize dimensions;
    AVAssetReader *reader;
    AVAsset *asset;
    AVAssetReaderOutput *output;
    BOOL limitPlaybackToFramerate;
    /** was reading in more frames aborted by the user?*/
    BOOL aborted;
    /** the nanosecond the last frame was read; used to calc the framerate*/
    dispatch_time_t popTime;
}
@property (readwrite, nonatomic) BOOL limitPlaybackToFramerate;
@property (readonly) CGSize dimensions;
/** The filter that is used to process a frame */
@property (atomic, retain) AbsVideoFilter* filter;
@property (atomic, readwrite) BOOL aborted;
@property (nonatomic, assign) float currentFramesPerSecond;
/* reset all settings and atributes */
-(void)reset;
/* prepare a new Video asset from the filesystem */
-(BOOL)loadAVAsset:(NSURL*)url;
/* starts only if an asset was loaded into the player */
-(void)startPlayer;

@end
