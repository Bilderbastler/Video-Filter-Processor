//
//  OpenCLFilter.h
//  Video Filter Processor
//
//  Created by Franzi on 03.12.12.
//
//

#import "AbsVideoFilter.h"
#import <OpenCL/opencl.h>

@interface OpenCLFilter : AbsVideoFilter{
    cl_int err;
    cl_context context;
    cl_device_id gpu;
    cl_device_id cpu;
    cl_command_queue cmd_queue;
    cl_image_format format;
    cl_program programm;
    cl_kernel imageKernel;
    cl_kernel bufferKernel;
    cl_sampler sampler;
}

@property BOOL useImage;

@end
