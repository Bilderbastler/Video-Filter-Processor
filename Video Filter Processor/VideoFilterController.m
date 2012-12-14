//
//  AbsVideoFilterController.m
//  Video Filter Processor
//
//  Created by Florian Neumeister on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoFilterController.h"

@implementation VideoFilterController
@synthesize videoFilter = _filter;

-(id) initWithWindowNibName:(NSString *)windowNibName filter:(AbsVideoFilter *)filter
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _filter = [filter retain];
        
    }
    
    return self;
}

- (void)dealloc {
    [_filter release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


@end
