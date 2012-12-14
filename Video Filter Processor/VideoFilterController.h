//
//  AbsVideoFilterController.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlayerModel.h"
@interface VideoFilterController : NSWindowController{
    AbsVideoFilter* _filter;
}
@property (nonatomic,retain)AbsVideoFilter* videoFilter;
/* creates an instance of the algorithm and gives it to the player */
-(id) initWithWindowNibName:(NSString *)windowNibName filter:(AbsVideoFilter *)filter;

@end
