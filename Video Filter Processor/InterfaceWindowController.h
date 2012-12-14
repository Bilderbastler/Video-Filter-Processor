//
//  InterfaceWindowController.h
//  Video Filter Processor
//
//  Created by Florian Neumeister on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbsVideoFilter.h"
#import "ColorWheel.h"

@interface InterfaceWindowController : NSWindowController {
    IBOutlet ColorWheel *gainColor;
    IBOutlet ColorWheel *gammaColor;
    IBOutlet ColorWheel *liftColor;
    
    IBOutlet NSSlider *gainSlider;
    IBOutlet NSSlider *gammaSlider;
    IBOutlet NSSlider *liftSlider;
    
    AbsVideoFilter *filter;
}

- (void)onLiftColorChange:(ColorWheel *)sender;
- (void)onGammaColorChange:(ColorWheel *)sender;
- (void)onGainColorChange:(ColorWheel *)sender;

- (IBAction)onLiftValueChange:(NSSlider *)sender;
- (IBAction)onGammaValueChange:(NSSlider *)sender;
- (IBAction)onGainValueChange:(NSSlider *)sender;

/* sets a new filter as the "model" of this controller when a 
 notification is received 
 */
- (void)updateFilterFromNotification:(NSNotification*)notification;
- (void)filter:(AbsVideoFilter*)aFilter;

@end
