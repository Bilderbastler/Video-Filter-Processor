//
//  ColorWheel.m
//  Simple Colorwheel
//
//  Created by Franzi on 14.10.12.
//
//

#import "ColorWheel.h"
#define WIDTH 200
#define HEIGHT 200
#define PADDING 20

@interface ColorWheel()
    @property (nonatomic, retain) NSImage* wheel;
    @property (nonatomic, retain) NSImage* pointer;
    @property (nonatomic, readonly) NSPoint colorPointer;
@end

@implementation ColorWheel

@synthesize wheel, pointer, colorPointer=_colorPointer;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pointer = [NSImage imageNamed:@"color-pointer.png"];
        self.wheel = [NSImage imageNamed:@"color-wheel.png"];
        self.colorPointer = NSZeroPoint;
        
        NSRect f = self.frame;
        f.size.width = WIDTH;
        f.size.height = HEIGHT;
        self.frame = f;
        
        
        }
    
    return self;
}



- (void)drawRect:(NSRect)dirtyRect
{
    // draw background
    float rectSize = fminf(dirtyRect.size.width, dirtyRect.size.height);
    NSRect dirtyCube = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, rectSize, rectSize);
    // add 10px padding to each side
    dirtyCube = NSInsetRect(dirtyCube, PADDING, PADDING);
    
    [self.wheel drawInRect:dirtyCube fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  	
  	NSPoint center = NSMakePoint(NSMidX(dirtyCube), NSMidY(dirtyCube));
    
    NSRect pointerRect = dirtyCube;
    pointerRect.origin = center;
    float shrinkFactor = 8.0;
    pointerRect.size.height = pointerRect.size.height / shrinkFactor;
    pointerRect.size.width = pointerRect.size.width / shrinkFactor;
    pointerRect = NSOffsetRect(pointerRect, pointerRect.size.width / -2, pointerRect.size.height / -2);
    pointerRect = NSOffsetRect(pointerRect, self.colorPointer.x, self.colorPointer.y);
  	[self.pointer drawInRect:pointerRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
}

-(NSSize)intrinsicContentSize{
    return NSMakeSize(WIDTH, HEIGHT);
}

-(void)setColorPointer:(NSPoint)colorCoordinates{
    float colorOffset = -0.25;
    _colorPointer = colorCoordinates;
    float hue = [self pointToAngleX:colorCoordinates.x y:colorCoordinates.y] / (2* pi);
    hue = fmodf((hue + colorOffset), 1.0) ;
    float sat = [self pointToLengthX:colorCoordinates.x y:colorCoordinates.y] / (WIDTH / 2 - PADDING);
    self.color = [NSColor colorWithCalibratedHue:hue saturation:sat brightness:1.0 alpha:1.0];
}

-(NSColor*)color{
    return [[_color retain ]autorelease];
}

-(void)setColor:(NSColor*)color{
    [self willChangeValueForKey:@"color"];
    [color retain];
    [_color release];
    _color = color;
    /*
     float x = sinf(color.hueComponent * 2 * pi) * (WIDTH / 2 - PADDING);
     float y = cosf(color.hueComponent * 2 * pi) * (WIDTH / 2 - PADDING);
     self.colorPointer = NSMakePoint(x, y);
     */
    [self setNeedsDisplay:YES];
    [self didChangeValueForKey:@"color"];
}

- (void)mouseDown:(NSEvent *)theEvent{
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint p = [self convertPoint:eventLocation fromView:nil];
    p.x -= self.frame.size.width / 2;
    p.y -= self.frame.size.height / 2;
    self.colorPointer = [self limitLengthOfPoint:p];
}

- (void)scrollWheel:(NSEvent *)theEvent{
    float drag = 0.2;
    NSPoint p = self.colorPointer;
    p.x -= theEvent.deltaX * drag;
    p.y += theEvent.deltaY * drag;
    self.colorPointer = [self limitLengthOfPoint:p];
}

- (NSPoint)limitLengthOfPoint:(NSPoint)point{
	float length = [self pointToLengthX:point.x y:point.y];
    if (length > (WIDTH / 2 -PADDING) && length > 0) {
        //normalize and limit to 200
        point = NSMakePoint(point.x / length * (WIDTH / 2 - PADDING), point.y / length * (WIDTH  / 2 - PADDING));
    }
    return point;
}

-(float)pointToLengthX:(float)x y:(float)y{
    return sqrtf((x * x) + (y * y));
}

-(float)pointToAngleX:(float)x y:(float)y{
    float angle = atan2f(y, x);
    
    if (angle < 0)
    {
        angle += pi * 2;
    }
    return angle;
}

- (void)dealloc
{
    self.pointer = nil;
    self.wheel = nil;
    
    [_color release];
    
    [super dealloc];
}

@end
