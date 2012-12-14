
__kernel void imageVideoFilter(read_only image2d_t input, write_only image2d_t output,   float4  shadows, float4 mids, float4 highlights){
    int     x = get_global_id(0);
    int     y = get_global_id(1);
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