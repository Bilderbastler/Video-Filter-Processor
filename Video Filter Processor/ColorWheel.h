//
//  ColorWheel.h
//  Simple Colorwheel
//
//  Created by Franzi on 14.10.12.
//
//

#import <Cocoa/Cocoa.h>

@interface ColorWheel : NSView{
    @private
    NSPoint _colorPointer;
    NSColor *_color;
}
@property (nonatomic, retain) NSColor* color;
@end
