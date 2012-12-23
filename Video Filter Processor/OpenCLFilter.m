//
//  OpenCLFilter.m
//  Video Filter Processor
//
//  Created by Franzi on 03.12.12.
//
//

#import "OpenCLFilter.h"

#include "filterKernel.cl.h"

@implementation OpenCLFilter

@synthesize useImage;
- (id)init
{
    self = [super init];
    if (self) {
        self.useImage = NO;
        
        err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_CPU, 1, &cpu, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"no cpu device found!");
        }
        
        err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_GPU, 1, &gpu, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"no gpu found for processing");
            gpu = cpu;
        }
        
        //gpu = cpu;
        
        cl_bool imageSupport = CL_FALSE;
        clGetDeviceInfo(gpu, CL_DEVICE_IMAGE_SUPPORT, sizeof(cl_bool), &imageSupport, NULL);
        if (imageSupport != CL_TRUE) {
            NSLog(@"Keine cl_image unterstützung auf dem Gerät");
        }
        
        context = clCreateContext(0, 1, &gpu, NULL, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"could not create cl context");
        }
        cmd_queue = clCreateCommandQueue(context, gpu, 0, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not create the cl command queue!");
        }
        
        // Bildformat:
        format.image_channel_order = CL_RGBA;
        format.image_channel_data_type = CL_UNSIGNED_INT8;
        
        // Programm erzeugen
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filterKernel.cl.gpu_32" ofType:@"bc" inDirectory:@"OpenCL"];
        const char* bitcodePath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
        size_t len = strlen(bitcodePath);
        programm = clCreateProgramWithBinary(context, 1, &gpu, &len, (const unsigned char**)&bitcodePath, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"could not create programm from bitcode");
        }
        err = clBuildProgram(programm, 0, NULL, NULL, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"CL program could not be build from binary: %i", err);
        }
        
        sampler = clCreateSampler(context, CL_FALSE, CL_ADDRESS_CLAMP, CL_FILTER_NEAREST, &err);
        if(err != CL_SUCCESS){
            NSLog(@"Could not create sampler");
        }
        
        size_t itemSizes[3];
        clGetDeviceInfo(gpu, CL_DEVICE_MAX_WORK_ITEM_SIZES, sizeof(size_t)*3, &itemSizes, NULL);

        size_t groupSize;
        clGetDeviceInfo(gpu, CL_DEVICE_MAX_WORK_GROUP_SIZE, sizeof(size_t), &groupSize, NULL);
        
        size_t itemDimension;
        clGetDeviceInfo(gpu, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, sizeof(size_t), &itemDimension, NULL);
        
        char buf[128];
        clGetDeviceInfo(gpu, CL_DEVICE_NAME, 128, buf, NULL);
        fprintf(stdout, "Device %s supports \n", buf);
        clGetDeviceInfo(gpu, CL_DEVICE_VERSION, 128, buf, NULL);
        fprintf(stdout, "%s\n", buf);
        clGetDeviceInfo(cpu, CL_DEVICE_NAME, 128, buf, NULL);
        fprintf(stdout, "Device %s supports \n", buf);
        clGetDeviceInfo(cpu, CL_DEVICE_VERSION, 128, buf, NULL);
        fprintf(stdout, "%s\n", buf);
        
        clFinish(cmd_queue);
        NSLog(@"fertig");
    }
    return self;
}

-(void)runAlgorithm{
    cl_mem inputData;
    cl_mem outputData;
    
    size_t globalWorkSize = bufferWidth * bufferHeight;
    
    cl_float4 shadows = {1.0f, self.blacks.r, self.blacks.g, self.blacks.b};
    cl_float4 gamma = {1.0f, self.mids.r, self.mids.g, self.mids.b};
    cl_float4 lights = {1.0f, self.highlights.r, self.highlights.g, self.highlights.b};

    if (self.useImage) {
        // Kernel erzeugen
        imageKernel = clCreateKernel(programm, "imageVideoFilter", &err);
        if (err != CL_SUCCESS) {
            NSLog(@"CL image kernel could not be created: %i", err);
        }
       
        inputData = clCreateImage2D(context, CL_MEM_READ_ONLY, &format, bufferWidth, bufferHeight, 0, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"INput image not created: %i", err);
        }
        outputData = clCreateImage2D(context, CL_MEM_WRITE_ONLY, &format, bufferWidth, bufferHeight, 0, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"output image not created: %i", err);
        }
        
        const size_t origin[3] = {0,0,0};
        const size_t region[3] = {bufferWidth, bufferHeight, 1};
        err = clEnqueueWriteImage(cmd_queue, inputData, CL_FALSE, origin, region, bytesPerRow, 0, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not upload input data: %i", err);
        }
        
        // enqueue arguments
        clSetKernelArg(imageKernel, 0, sizeof(cl_mem), &inputData);
        clSetKernelArg(imageKernel, 1, sizeof(cl_mem), &outputData);
        clSetKernelArg(imageKernel, 2, sizeof(cl_sampler), &sampler);
        clSetKernelArg(imageKernel, 3, sizeof(cl_double3), &shadows);
        clSetKernelArg(imageKernel, 4, sizeof(cl_double3), &gamma);
        clSetKernelArg(imageKernel, 5, sizeof(cl_double3), &lights);
     
        // start kernel!!
        err = clEnqueueNDRangeKernel(cmd_queue, imageKernel, 1, NULL, &globalWorkSize, NULL, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not run kernel: %i", err);
        }
        
        // read output image
        
        err = clEnqueueReadImage(cmd_queue, outputData, CL_TRUE, origin, region, 0, 0, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not read results: %i", err);
        }
        
        clReleaseKernel(imageKernel);
        
    } else {
        bufferKernel = clCreateKernel(programm, "bufferVideoFilter", &err);
        if (err != CL_SUCCESS) {
            NSLog(@"CL buffer kernel could not be created: %i", err);
        }
        
        // create buffer       
        inputData = clCreateBuffer(context, CL_MEM_READ_ONLY, bufferWidth * bufferHeight * bytesPerPixel, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"INput image not created : %i", err);
        }
        outputData = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bufferHeight * bufferWidth * bytesPerPixel, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"output image not created : %i", err);
        }

        err = clEnqueueWriteBuffer(cmd_queue, inputData, CL_FALSE, 0, bufferWidth * bufferHeight * bytesPerPixel, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not copy frame into device memory");
        }
        NSLog(@"pixel vorher: %hhu", base[100001]);

        // enqueue arguments
        
        err = clSetKernelArg(bufferKernel, 0, sizeof(cl_mem), &inputData);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not set input buffer argument: %i", err);
        }
        
        err = clSetKernelArg(bufferKernel, 1, sizeof(cl_mem), &outputData);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not set output buffer argument: %i", err);
        }
        
        err = clSetKernelArg(bufferKernel, 2, sizeof(cl_float4), &shadows);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not set shadowr argument: %i", err);
        }
        err = clSetKernelArg(bufferKernel, 3, sizeof(cl_float4), &gamma);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not set gamma argument: %i", err);
        }
        err = clSetKernelArg(bufferKernel, 4, sizeof(cl_float4), &lights);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not set highlights argument: %i", err);
        }
        
        
        // start kernel
        err = clEnqueueNDRangeKernel(cmd_queue, bufferKernel, 1, NULL, &globalWorkSize, NULL, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not run kernel: %i", err);
        }
        NSLog(@"pixel vorher: %hhu", base[100001]);
        // read output data
        err = clEnqueueReadBuffer(cmd_queue, outputData, CL_TRUE, 0 , bufferHeight * bufferWidth * bytesPerPixel, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not read results");
        }
        NSLog(@"pixel nachher: %hhu", base[100001]);

        clReleaseKernel(bufferKernel);
    }
    
    clReleaseMemObject(inputData);
    clReleaseMemObject(outputData);   
    
}

-(void)dealloc{
    clReleaseKernel(imageKernel);
    clReleaseKernel(bufferKernel);
    clReleaseSampler(sampler);
    clReleaseProgram(programm);
    clReleaseCommandQueue(cmd_queue);
    clReleaseContext(context);
    clReleaseDevice(cpu);
    clReleaseDevice(gpu);
    
    [super dealloc];
}

@end
