//
//  GCDFilterController.h
//  Video Filter Processor
//
//  Created by Franzi on 16.11.12.
//
//

#import "VideoFilterController.h"

@interface GCDFilterController : VideoFilterController
@property (assign, nonatomic) float tasks;
- (IBAction)priorityRadioGroup:(NSMatrix *)sender;
@property (assign) IBOutlet NSSlider *slider;
@property (assign) IBOutlet NSTextField *tasksField;
- (IBAction)changeDispatchMethod:(NSButtonCell *)sender;


@end
