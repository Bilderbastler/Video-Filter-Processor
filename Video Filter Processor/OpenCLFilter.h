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
    cl_context gpuContext;
    cl_context cpuContext;
    cl_device_id gpu;
    cl_device_id cpu;
    cl_command_queue gpu_queue;
    cl_command_queue cpu_queue;
    cl_image_format format;
    cl_program gpuProgramm;
    cl_program cpuProgramm;
    cl_kernel imageKernel;
    cl_kernel bufferKernel;
    cl_sampler gpuSampler;
    cl_sampler cpuSampler;
    
    cl_mem inputImage;
    cl_mem outputImage;
    cl_mem inputBuffer;
    cl_mem outputBuffer;
}

@property BOOL useImage;
@property BOOL useGPU;
@property size_t localWorksize;

@end
