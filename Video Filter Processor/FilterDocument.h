//
//  Document.h
//  Video Filter Processor
//
//  Created by  Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlayerModel.h"
#import "VideoFilterController.h"
#import "ColorWheelsWindowController.h"
@interface FilterDocument : NSDocument <NSWindowDelegate>{
    NSWindowController* mainWindowController;
    ColorWheelsWindowController* uiController;
    VideoFilterController* filterController;
}

@property (retain) PlayerModel *player;

-(void)setFilter:(VideoFilterController*)filter;
@end
