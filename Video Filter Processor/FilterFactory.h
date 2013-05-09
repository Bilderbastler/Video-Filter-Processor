//
//  FilterFactory.h
//  Video Filter Processor
//
//  Created by  Neumeister on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFilterController.h"

enum {
    FilterSingleThread = 0,
    FilterNSThread = 1,
    FilterGCD = 2,
    FilterOpenCL = 3,
    FilterOpenGL = 4,
    FilterOperationQueue = 5
};
typedef NSInteger VideoFilterValue;
@interface FilterFactory : NSObject
-(VideoFilterController*)filterWithName:(VideoFilterValue)filtername;
@end
