
__kernel void imageVideoFilter(read_only image2d_t input, write_only image2d_t output, sampler_t sampler, float4  shadows, float4 mids, float4 highlights){
    int     id = get_global_id(0);
    int id2 = get_global_id(1);
    
    int width = get_image_width(input);
    int height = get_image_height(input);
    int y = id / width;
    int x = id % width;
    int2 pos = (int2)(x, y);


    
   
       
    // works on cpu
    //float4 pixel = read_imagef(input, sampler, pos);
    uint4 uipixel = read_imageui(input, sampler, pos);
    
    
    float4 pixel = convert_float4(uipixel);
    
    pixel = pixel / 255.0f;
    
    pixel = pixel * (highlights + 1.0f); // highlights
    pixel = pixel + shadows; // shadows
    
    pixel = clamp(pixel, 0.0f, 1.0f);
    
    //pixel = pow(pixel, (1.0f - mids)); // gamma die orginal pow() funktion ist zu kostspielig, powr() und half_powr() sind nur 1 FPS schneller

    
    // WTF ?! das gibt auf der gpu GANZ andere werte!
    pixel = native_powr(pixel, (1.0f - mids)); // gamma
    
    pixel = pixel * 255.0f;
    
    // ignore computations on the alpha channel
    pixel.x = 255.0f;
    
    
    uipixel = convert_uint4(pixel);
    write_imageui(output, pos, uipixel);
    //write_imagef(output, pos, pixel);
}

__kernel void bufferVideoFilter(__global unsigned char*  input, __global unsigned char * output,  float4  shadows, float4 mids, float4 highlights){
    int     x = get_global_id(0) * 4;
    float4 pixel = (float4) (input[x], input[x+1], input[x+2], input[x+3]);
    
    pixel = pixel / 255.0f;
    
    pixel = pixel * (highlights + 1.0f); // highlights
    pixel = pixel + shadows; // shadows
    
    pixel = clamp(pixel, 0.0f, 1.0f);
//    pixel = pow(pixel, (1.0f - mids)); // gamma die orginal pow() funktion ist zu kostspielig, powr() und half_powr() sind nur 1 FPS schneller
    float4 localMids = 1.0f - mids;
    pixel = native_powr(pixel, localMids); // gamma
    pixel = pixel * 255.0f;

    output[x] = 255; // irgnore alpha chanel
    output[x+1] = pixel.y;
    output[x+2] = pixel.z;
    output[x+3] = pixel.w;
}

