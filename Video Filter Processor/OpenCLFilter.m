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
        self.useImage = YES;
        self.useGPU = YES;
        self.localWorksize = 0;
        
        err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_CPU, 1, &cpu, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"no cpu device found!");
        }
        
        err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_GPU, 1, &gpu, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"no gpu found for processing");
        }
               
        cl_bool imageSupport = CL_FALSE;
        clGetDeviceInfo(gpu, CL_DEVICE_IMAGE_SUPPORT, sizeof(cl_bool), &imageSupport, NULL);
        if (imageSupport != CL_TRUE) {
            NSLog(@"Keine cl_image unterstützung auf dem Gerät");
        }
        
        gpuContext = clCreateContext(0, 1, &gpu, NULL, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"could not create gpu cl context");
        }
        cpuContext = clCreateContext(0, 1, &cpu, NULL, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"could not create cpu cl context");
        }
        gpu_queue = clCreateCommandQueue(gpuContext, gpu, 0, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not create the cl command queue!");
        }
        cpu_queue = clCreateCommandQueue(cpuContext, cpu, 0, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not create the cl command queue!");
        }
        
        // Bildformat:
        format.image_channel_order = CL_RGBA;
        format.image_channel_data_type = CL_UNSIGNED_INT8;
        
        [self addObserver:self forKeyPath:@"useGPU" options:NSKeyValueObservingOptionNew context:nil];
        
        // Programm erzeugen
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filterKernel.cl.gpu_32" ofType:@"bc" inDirectory:@"OpenCL"];
        const char* bitcodePath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
        size_t len = strlen(bitcodePath);
        
        gpuProgramm = clCreateProgramWithBinary(gpuContext, 1, &gpu, &len, (const unsigned char**)&bitcodePath, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"could not create programm from bitcode");
        }
        cpuProgramm = clCreateProgramWithBinary(cpuContext, 1, &cpu, &len, (const unsigned char**)&bitcodePath, NULL, &err);
        if (err != CL_SUCCESS) {
            NSLog(@"could not create programm from bitcode");
        }
        err = clBuildProgram(gpuProgramm, 0, NULL, NULL, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"CL program could not be build from binary: %i", err);
        }
        err = clBuildProgram(cpuProgramm, 0, NULL, NULL, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"CL program could not be build from binary: %i", err);
        }
        
        gpuSampler = clCreateSampler(gpuContext, CL_FALSE, CL_ADDRESS_CLAMP, CL_FILTER_NEAREST, &err);
        if(err != CL_SUCCESS){
            NSLog(@"Could not create sampler");
        }
        cpuSampler = clCreateSampler(cpuContext, CL_FALSE, CL_ADDRESS_CLAMP, CL_FILTER_NEAREST, &err);
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
    }
    return self;
}

-(void)runAlgorithm{
    cl_program programm;
    cl_context context;
    cl_command_queue cmd_queue;
    cl_sampler sampler;
    
    if (self.useGPU) {
        programm = gpuProgramm;
        context = gpuContext;
        cmd_queue = gpu_queue;
        sampler = gpuSampler;
    } else {
        programm = cpuProgramm;
        context = cpuContext;
        cmd_queue = cpu_queue;
        sampler = cpuSampler;
    }
    
    if (inputImage == NULL || outputImage == NULL || inputBuffer == NULL || outputBuffer == NULL) {
        [self createImageMemory];
    }    
    
    size_t globalWorkSize = bufferWidth * bufferHeight;
    size_t * localsize;
    if (self.localWorksize == 0) {
        localsize = NULL;
    }else{
        localsize = & _localWorksize;
    }
    
    cl_float4 shadows = {1.0f, self.blacks.r, self.blacks.g, self.blacks.b};
    cl_float4 gamma = {1.0f, self.mids.r, self.mids.g, self.mids.b};
    cl_float4 lights = {1.0f, self.highlights.r, self.highlights.g, self.highlights.b};

    
    if (self.useImage) {
        
        
        // Kernel erzeugen
        imageKernel = clCreateKernel(programm, "imageVideoFilter", &err);
        if (err != CL_SUCCESS) {
            NSLog(@"CL image kernel could not be created: %i", err);
        }
        
        const size_t origin[3] = {0,0,0};
        const size_t region[3] = {bufferWidth, bufferHeight, 1};
        err = clEnqueueWriteImage(cmd_queue, inputImage, CL_FALSE, origin, region, bytesPerRow, 0, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not upload input data: %i", err);
        }
        
        // enqueue arguments
        clSetKernelArg(imageKernel, 0, sizeof(cl_mem), &inputImage);
        clSetKernelArg(imageKernel, 1, sizeof(cl_mem), &outputImage);
        clSetKernelArg(imageKernel, 2, sizeof(cl_sampler), &sampler);
        clSetKernelArg(imageKernel, 3, sizeof(cl_double3), &shadows);
        clSetKernelArg(imageKernel, 4, sizeof(cl_double3), &gamma);
        clSetKernelArg(imageKernel, 5, sizeof(cl_double3), &lights);
     
        // start kernel!!
        err = clEnqueueNDRangeKernel(cmd_queue, imageKernel, 1, NULL, &globalWorkSize, localsize , 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not run kernel: %i", err);
        }
        
        // read output image
        
        err = clEnqueueReadImage(cmd_queue, outputImage, CL_TRUE, origin, region, 0, 0, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not read results: %i", err);
        }
        
        clReleaseKernel(imageKernel);
        
    } else {
        cl_mem buffer;
        
        bufferKernel = clCreateKernel(programm, "bufferVideoFilter", &err);
        if (err != CL_SUCCESS) {
            NSLog(@"CL buffer kernel could not be created: %i", err);
        }
        
       
        if (YES) {
            buffer = inputBuffer;

        }else{
            buffer = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_USE_HOST_PTR, bufferWidth * bufferHeight * bytesPerPixel, base, &err);
            if (err != CL_SUCCESS) {
                NSLog(@"INput image not created : %i", err);
            }
        }
        err = clEnqueueWriteBuffer(cmd_queue, buffer, CL_FALSE, 0, bufferWidth * bufferHeight * bytesPerPixel, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not copy frame into device memory");
        }
        
        // enqueue arguments
        
        err = clSetKernelArg(bufferKernel, 0, sizeof(cl_mem), &buffer);
        if (err != CL_SUCCESS) {
            NSLog(@"Could not set input buffer argument: %i", err);
        }
        
        err = clSetKernelArg(bufferKernel, 1, sizeof(cl_mem), &outputBuffer);
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
        err = clEnqueueNDRangeKernel(cmd_queue, bufferKernel, 1, NULL, &globalWorkSize, localsize, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not run kernel: %i", err);
        }
        // read output data
        err = clEnqueueReadBuffer(cmd_queue, outputBuffer, CL_TRUE, 0 , bufferHeight * bufferWidth * bytesPerPixel, base, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            NSLog(@"could not read results");
        }

        clReleaseKernel(bufferKernel);
    }
    
  
    
}

-(void)createImageMemory{
    clReleaseMemObject(inputImage);
    clReleaseMemObject(outputImage);
    clReleaseMemObject(inputBuffer);
    clReleaseMemObject(outputBuffer);
    
    cl_context context;
    if(self.useGPU){
        context = gpuContext;
    }else{
        context = cpuContext;
    }
    
    // create buffer
    inputBuffer = clCreateBuffer(context, CL_MEM_READ_ONLY, bufferWidth * bufferHeight * bytesPerPixel, NULL, &err);
    if (err != CL_SUCCESS) {
        NSLog(@"INput image not created : %i", err);
    }
    outputBuffer = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bufferHeight * bufferWidth * bytesPerPixel, NULL, &err);
    if (err != CL_SUCCESS) {
        NSLog(@"output image not created : %i", err);
    }
    
    inputImage = clCreateImage2D(context, CL_MEM_READ_ONLY, &format, bufferWidth, bufferHeight, 0, NULL, &err);
    if (err != CL_SUCCESS) {
        NSLog(@"INput image not created: %i", err);
    }
    outputImage = clCreateImage2D(context, CL_MEM_WRITE_ONLY, &format, bufferWidth, bufferHeight, 0, NULL, &err);
    if (err != CL_SUCCESS) {
        NSLog(@"output image not created: %i", err);
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // kritisch, sollte eigentlich syncronisiert werden… ja sollte es…
    if ([keyPath isEqualTo:@"useGPU"]) {
        [self createImageMemory];
    }
}

-(void)dealloc{
  //  clReleaseKernel(imageKernel);
  //  clReleaseKernel(bufferKernel);
    clReleaseSampler(gpuSampler);
    clReleaseSampler(cpuSampler);
    clReleaseProgram(gpuProgramm);
    clReleaseProgram(cpuProgramm);
    clReleaseCommandQueue(gpu_queue);
    clReleaseCommandQueue(cpu_queue);
    clReleaseContext(cpuContext);
    clReleaseContext(gpuContext);
    clReleaseDevice(cpu);
    clReleaseDevice(gpu);
    
    clReleaseMemObject(inputBuffer);
    clReleaseMemObject(outputBuffer);
    clReleaseMemObject(inputImage);
    clReleaseMemObject(outputImage);
    
    [super dealloc];
}

@end
