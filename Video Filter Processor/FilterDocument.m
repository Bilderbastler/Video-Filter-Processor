//
//  Document.m
//  Video Filter Processor
//
//  Created by  Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterDocument.h"
#import "VideoWindowController.h"
#import <AVFoundation/AVFoundation.h>
#import "AbsVideoFilter.h"
#import "ColorWheelsWindowController.h"

@implementation FilterDocument
@synthesize player;
- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
        PlayerModel *pl = [[PlayerModel alloc]init];
        self.player = pl;
        [pl release];      
    }
    return self;
}

- (void)dealloc {
    [mainWindowController release];
    [uiController release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"FilterDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError{
    return YES;
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}



- (void)makeWindowControllers{
	
    /* Create the user interface for this document, but don't show it yet. The default implementation of this method invokes [self windowNibName], creates a new window controller using the resulting nib name (if it is not nil), specifying this document as the nib file's owner, and then invokes [self addWindowController:theNewWindowController] to attach it. You can override this method to use a custom subclass of NSWindowController or to create more than one window controller right away. NSDocumentController invokes this method when creating or opening new documents.
     */
	mainWindowController = [[VideoWindowController alloc] initWithWindowNibName:[self windowNibName]];
    [self addWindowController: mainWindowController];
    
    // [self.player addObserver:mainWindowController forKeyPath:@"currentFramesPerSecond" options:NSKeyValueObservingOptionNew context:nil];
    
    
    uiController = [[ColorWheelsWindowController alloc] initWithWindowNibName:@"Interface"];
    [self addWindowController:uiController];
    
    // set the document as the delegat so it can respond to the closing of the document window
    [[mainWindowController window] setDelegate:self];
    
    // Create an asset with our URL, asychronously load its tracks, its duration, and whether it's playable or protected.
	// When that loading is complete, configure a player to play the asset.
    
    // reset the player, just in case…
    [self.player reset];
    
    
    // TODO set an actuall filter !!
    AbsVideoFilter* filter = [[AbsVideoFilter alloc]init];
    player.filter = filter;
    [filter release];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    	BOOL success = [self.player loadAVAsset:[self fileURL]];  
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                // set widow to the aspect size of the movie file - has to be done on the main queue
                [mainWindowController.window setContentSize:player.dimensions];
                [mainWindowController.window setContentAspectRatio:player.dimensions];                
            });
            // now load the frames to process and display them
            [player startPlayer];            
        }else{
            NSLog(@"couldn't load the video file");
        }
    });
}

-(void)setFilter:(VideoFilterController*)filter{
    [filter retain];
    [filterController close];
    [filterController release];
    filterController = filter;
    
    //give the actual implementation of the algorithm to the player.
    player.filter = filter.videoFilter;
    
    [self removeWindowController:filterController];
    [self addWindowController:filter];
    [filter showWindow:nil];
}


-(void)windowWillClose:(NSNotification *)notification{
    // stop processing more frames;
	player.aborted = true;
    [uiController close];
    [filterController close];
}

-(void)restoreDocumentWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler{
    [super restoreDocumentWindowWithIdentifier:identifier state:state completionHandler:completionHandler];
    
    /*
    // restore the interface window
    uiController = [[InterfaceWindowController alloc] initWithWindowNibName:@"Interface"];
    [self addWindowController:uiController];
    
    // connect interface to the filter instance
    [(InterfaceWindowController*) uiController filter:self.player.filter];
    */
    completionHandler([uiController window], nil);
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
