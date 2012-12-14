//
//  Document.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlayerModel.h"
#import "VideoFilterController.h"
#import "InterfaceWindowController.h"
@interface Document : NSDocument <NSWindowDelegate>{
    NSWindowController* mainWindowController;
    InterfaceWindowController* uiController;
    VideoFilterController* filterController;
}

@property (retain) PlayerModel *player;

-(void)setFilter:(VideoFilterController*)filter;
@end
