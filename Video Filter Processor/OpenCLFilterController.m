//
//  OpenCLFilterController.m
//  Video Filter Processor
//
//  Created by Franzi on 16.11.12.
//
//

#import "OpenCLFilterController.h"

@interface OpenCLFilterController ()

@end

@implementation OpenCLFilterController

-(id)initWithWindowNibName:(NSString *)windowNibName filter:(AbsVideoFilter *)filter{
    self = [super initWithWindowNibName:windowNibName filter:filter];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
