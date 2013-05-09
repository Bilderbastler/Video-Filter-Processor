//
//  AbsVideoFilterTest.m
//  Video Filter Processor
//
//  Created by Franzi on 26.04.13.
//
//

#import "AbsVideoFilterTest.h"



@implementation AbsVideoFilterTest
-(void)setUp{  
    _filter = [[AbsVideoFilter alloc] init];
    STAssertNotNil(_filter, @"could not create filter object");
    
    _grayColor = [[NSColor colorWithCalibratedRed:0.5f green:0.5f blue:0.5f alpha:1.0f] retain];
}

-(void)tearDown{
    [_filter release];
    [_grayColor release];
}

-(void)testGammaChannelCorrection{
    _filter.useVector = YES;
    
    unsigned char result;
    unsigned char pixelArray[4] = {255, 127, 127, 127};
    unsigned char* baseAdress = &pixelArray[0];
    
    struct RGBData midValues;
    midValues.r = 0;
    midValues.g = 0;
    midValues.b = 0;
    _filter.mids = midValues;
    
    [_filter calculateCorrectionForPixel: baseAdress];
    STAssertTrue(pixelArray[1] == 127, @"there was a value change, when none was expected");
    
    pixelArray[0] = 255;
    for (int i = 1; i < 4 ; i++) {
        pixelArray[i] = 127;
    }
    midValues.r = 1;
    midValues.g = 1;
    midValues.b = 1;
    _filter.mids = midValues;
    
    [_filter calculateCorrectionForPixel:baseAdress];
    STAssertTrue(pixelArray[1] > 127, @"no increase of value after raised gamma");
    
    pixelArray[0] = 255;
    for (int i = 1; i < 4 ; i++) {
        pixelArray[i] = 127;
    }
    midValues.r = -0.5;
    midValues.g = -0.5;
    midValues.b = -0.5;
    _filter.mids = midValues;
    [_filter calculateCorrectionForPixel:baseAdress];
    STAssertTrue(pixelArray[1] < 127, @"no decrease of value after lowered gamma");
    STAssertTrue(pixelArray[1] > 60, @"the value was decreased too much");
    
   
    _filter.useVector = NO;
    
    result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:0 gain:0];
    STAssertTrue(result == 127, @"there was a value change, when none was expected");
    
    result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:1 gain:0];
    STAssertTrue(result > 127, @"no increase of value after raised gamma");
    
    result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:-0.5 gain:0];
    STAssertTrue(result < 127, @"no decrease of value after lowered gamma");
    STAssertTrue(result > 60, @"the value was decreased too much");
    
    result = [_filter calculateCorrectionForChannel:255 lift:0 gamma:1.0 gain:0];
    STAssertTrue(result == 255, @"value should be white");
    
    result = [_filter calculateCorrectionForChannel:0 lift:0 gamma:0.5 gain:0];
    STAssertTrue(result == 0, @"value shoould be black");
    
    result = [_filter calculateCorrectionForChannel:0 lift:0 gamma:-0.5 gain:0];
    STAssertTrue(result == 0, @"value shoould be black");
    
    result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:0.5 gain:0];
    STAssertTrue(result > 127, @"value shoould be lighter");
    
    result = [_filter calculateCorrectionForChannel:200 lift:1 gamma:1 gain:1];
    STAssertTrue(result == 255, @"value shoould be white");
    
}

-(void)testGainChannelCorrection{
    unsigned char result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:0 gain:0];
    STAssertTrue(result == 127, @"the value should not have changed");
    
    result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:0 gain:0.5];
    STAssertTrue(result > 127, @"the value should  have increased");
    
    result = [_filter calculateCorrectionForChannel:127 lift:0 gamma:0 gain:-0.5];
    STAssertTrue(result < 127, @"the value should  have decreased");
    
    result = [_filter calculateCorrectionForChannel:130 lift:0 gamma:0 gain:1];
    STAssertTrue(result == 255, @"the value should should be max");
    NSLog(@"%i", result);
    result = [_filter calculateCorrectionForChannel:130 lift:0 gamma:0 gain:-1];
    STAssertTrue(result == 0, @"the value should should be min");
}
-(void)testPositiveLift{
    unsigned char pixel[4] = {255, 0,0,0};
    [_filter calculateCorrectionForPixel:pixel];
}



//
// Test helper methods and objects, that are used in this test.
//

-(void)testBufferCreation{
    return;
    
    
    int size = 4;
    CVPixelBufferRef buffer = [self createBufferWithColor:[NSColor redColor] Width:size Height:size];
    
    STAssertTrue(buffer != NULL, @"Buffer is NULL");
    STAssertTrue(CVPixelBufferGetWidth(buffer) == size, @"size of buffer does not match");
    
    unsigned char coloredPixel[4] = {255, 17, 120, 189};
    bool equal;
    NSColor* coloredColor = [NSColor colorWithDeviceRed:(coloredPixel[1] / 255.f)
                                                      green:(coloredPixel[2] / 255.f)
                                                       blue:(coloredPixel[3] / 255.f)
                                                      alpha:(coloredPixel[0] / 255.f)];
    STAssertTrue([coloredColor alphaComponent] > 0, @"alpha is 0");
    STAssertTrue([coloredColor redComponent] > 0, @"red is 0");
    STAssertTrue([coloredColor greenComponent] > 0, @"green is 0");
    STAssertTrue([coloredColor blueComponent] > 0, @"blue is 0");

    CVPixelBufferRef coloredBuffer = [self createBufferWithColor:coloredColor];
    equal = [self compareFirstPixelInBuffer:coloredBuffer withValues: coloredPixel];
    STAssertTrue(equal, @"colors in buffer are not equal to input values to the creating mehod");
    
    unsigned char lightGrayPixel[4] = {255, 128, 128,128};
    unsigned char grayPixel[4] = {255, 127, 127, 127};
    
    CVPixelBufferRef grayBuffer = [self createBufferWithColor:_grayColor];
    equal = [self compareFirstPixelInBuffer:grayBuffer withValues:grayPixel];
    STAssertTrue(equal, @"gray buffer does not contain color values of 127");
    equal = [self compareFirstPixelInBuffer:grayBuffer withValues:lightGrayPixel];
    STAssertFalse(equal, @"gray buffer acualy contains pixel values of 128");
}


-(void)testNSColorMethods{
    CGFloat val = 1.f;
    STAssertEquals([[NSColor redColor] redComponent] , val, @"Red Channel is not 1.0f on red color");
}

-(void)testPixelComparissionFromBuffer{
    unsigned char comparePixel[4] = {255, 255, 0, 0};
    CVPixelBufferRef buffer = [self createBufferWithColor:[NSColor redColor] Width:8 Height:4];
    BOOL equal = [self compareFirstPixelInBuffer:buffer withValues: comparePixel];
    STAssertTrue(equal, @"comparissoin method does not work correctly");
    
    unsigned char differentPixel[4] = {255, 0, 255, 255};
    equal = [self compareFirstPixelInBuffer:buffer withValues:differentPixel];
    STAssertFalse(equal, @"comparisoin method says unequal pixela are equal");    
}

-(CVPixelBufferRef)createBufferWithColor:(NSColor*)color{
    return [self createBufferWithColor:color Width:2 Height:2];
}

-(CVPixelBufferRef)createBufferWithColor:(NSColor*)color Width:(uint)width Height:(uint)height{
    CVPixelBufferRef buffer;
    int bitmapSize = width * height * 4;
    CVPixelBufferCreate(NULL, width, height, kCVPixelFormatType_32ARGB, NULL, &buffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    unsigned char* bitmap = CVPixelBufferGetBaseAddress(buffer);
    for (int i = 0; i < bitmapSize; i += 4) {
        int channelValue;
        channelValue =  [color alphaComponent] * 255;
        bitmap[i] = channelValue;
        channelValue = [color redComponent] * 255;
        bitmap[i+1] = channelValue;
        channelValue =  [color greenComponent] * 255;
        bitmap[i+2] = channelValue;
        channelValue = [color blueComponent] * 255;
        bitmap[i+3] = channelValue;
    }
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return buffer;
}

-(BOOL)compareFirstPixelInBuffer:(CVPixelBufferRef)buffer withValues:(unsigned char*)pixelArray{
    BOOL isEqual = YES;
    CVPixelBufferLockBaseAddress(buffer, 0);
    unsigned char* bitmap = CVPixelBufferGetBaseAddress(buffer);
    for (int i = 0; i < 4; i++) {
        if (bitmap[i] != pixelArray[i]) {
            isEqual = NO;
            break;
        }
    }
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return isEqual;
}





@end
