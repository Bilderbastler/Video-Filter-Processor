//
//  InterfaceWindowController.m
//  Video Filter Processor
//
//  Created by Florian Neumeister on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InterfaceWindowController.h"
@interface InterfaceWindowController()
-(NSColor*)resetLuminanceOfColor:(NSColor*)color;
-(void)resetUIElements;
-(void)toggleUIElements:(BOOL)active;
@end
@implementation InterfaceWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFilterFromNotification:) name: NEW_FILTER_NOTIFICATION object:nil];        
        
    }
    
    return self;
}
-(void)windowDidLoad{
    NSLog(@"Fenster geladen");
    [self toggleUIElements:NO];
    
    if (gainColor != nil) {
        [gainColor addObserver:self forKeyPath:@"color" options:nilHandleErr context:nil];
    }
    if (liftColor != nil) {
        [liftColor addObserver:self forKeyPath:@"color" options:nilHandleErr context:nil];
    }
    if (gammaColor != nil) {
        [gammaColor addObserver:self forKeyPath:@"color" options:nilHandleErr context:nil];
    }
    
    [self.window makeKeyAndOrderFront:self];
    
    [super windowDidLoad];  
}






- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == liftColor) {
        [self onLiftColorChange:object];
    }else if (object == gammaColor){
        [self onGammaColorChange:object];
    }else if (object == gainColor){
        [self onGainColorChange:object];
    }
    
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (void)dealloc {
    
    [gainColor removeObserver:self forKeyPath:@"color"];
    [liftColor removeObserver:self forKeyPath:@"color"];
    [gammaColor removeObserver:self forKeyPath:@"color"];
    [filter release];
    [super dealloc];
}
/*
 Color Changes
 */
- (void)onGainColorChange:(ColorWheel *)sender {
    // TODO: im ersten Schritt Color Wells ignorieren
    filter.highlights = [self wrapDataFromColorWheel:sender applyLuminance:gainSlider.floatValue];
}
- (void)onLiftColorChange:(ColorWheel *)sender {
    filter.blacks = [self wrapDataFromColorWheel:sender applyLuminance:liftSlider.floatValue];
}
- (void)onGammaColorChange:(ColorWheel *)sender {
    filter.mids = [self wrapDataFromColorWheel:sender applyLuminance:gammaSlider.floatValue];
}

-(struct RGBData)wrapDataFromColorWheel:(ColorWheel*)cw applyLuminance:(CGFloat)luminance{
    struct RGBData values;
    //NSColor* color = [NSColor colorWithDeviceHue:well.color.hueComponent saturation:well.color.saturationComponent brightness:luminance alpha:1.0];
    NSColor* color = cw.color;
    
    values = [self convertColor:color withLuminaceChange:luminance];
    /*
    values.r = well.color.redComponent * luminance;
    values.g = well.color.greenComponent * luminance;
    values.b = well.color.blueComponent * luminance;
     */
    return values;
}
/**
 converts an NSColor Object into an RGBData Struct with hue and saturation values from the color well
 and the luminance value from the slider.
 */
-(struct RGBData)convertColor:(NSColor*)color withLuminaceChange:(CGFloat)luminance{
    struct RGBData values;
    
    NSColor* adjustedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat hueComp = adjustedColor.hueComponent;
    CGFloat satComp = adjustedColor.saturationComponent;
    adjustedColor = [NSColor colorWithDeviceHue: hueComp saturation: satComp brightness: 1.0 alpha:1.0];
    
    
    float red, green, blue, average, redOffset, greenOffset, blueOffset;
    red = adjustedColor.redComponent;
    green = adjustedColor.greenComponent;
    blue = adjustedColor.blueComponent;
    
    // average luminance
    average = (red + green + blue) / 3.0;
    
    // calculate the offset from the average luminance per color channel
    redOffset = red - average;
    greenOffset = green - average;
    blueOffset = blue - average;
    
    values.r = luminance + redOffset;
    values.g = luminance + greenOffset;
    values.b = luminance + blueOffset;
    /*
    values.r = adjustedColor.redComponent * luminance;
    values.g = adjustedColor.greenComponent * luminance;
    values.b = adjustedColor.blueComponent * luminance;
     */
	return values;
}

/*
 Luminance Changes
 */
- (IBAction)onLiftValueChange:(NSSlider *)sender {    
    struct RGBData values = [self convertColor:liftColor.color withLuminaceChange:sender.floatValue];
    filter.blacks = values;
}

- (IBAction)onGammaValueChange:(NSSlider *)sender {
    
    struct RGBData values = [self convertColor:gammaColor.color withLuminaceChange:sender.floatValue];

    filter.mids = values;
}

- (IBAction)onGainValueChange:(NSSlider *)sender {
    
    struct RGBData values = [self convertColor:gainColor.color withLuminaceChange:sender.floatValue];
    filter.highlights = values;
}

-(void)updateFilterFromNotification:(NSNotification *)notification{
    AbsVideoFilter* theNewFilter = (AbsVideoFilter*) [notification object];
	[self filter:theNewFilter];
}

-(void)filter:(AbsVideoFilter *)aFilter{
    [aFilter retain];
    [filter release];
    filter = aFilter;
    
    [self resetUIElements];
    
    if (filter == nil) {
        [self toggleUIElements:NO];
    }else{
        [self toggleUIElements:YES];
    }

}

-(NSColor*)resetLuminanceOfColor:(NSColor*)color{
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    return  [NSColor colorWithDeviceHue:[color hueComponent]
                             saturation:[color saturationComponent]
                             brightness:1.0
                                  alpha:1.0];
}

/*
 sets all UI Elements to their default value
 */
-(void)resetUIElements{
    liftSlider.floatValue = 0.0;
    gammaSlider.floatValue = 0.0;
    gainSlider.floatValue = 0.0;
    
    [liftColor setColor:[NSColor whiteColor]];
    [gammaColor setColor:[NSColor whiteColor]];
    [gainColor setColor:[NSColor whiteColor]];
    
}
/*
 sets toogles the ui-elements on or off
 */
-(void)toggleUIElements:(BOOL)active{
    [liftSlider setEnabled:active];
    [gammaSlider setEnabled:active];
    [gainSlider setEnabled:active];
    
    /*
    [liftColor setEnabled:active];
    [gammaColor setEnabled:active];
    [gainColor setEnabled:active];
     */
}


@end
