#include <stdint.h>

#ifndef HKR33_HUANG_MEDFILT2_H
#define HKR33_HUANG_MEDFILT2_H

    struct dims
    {
        int M;
        int N;  
    };

    struct window_edge 
    {
        int** o;
        int** n;
    };

    void free_2d_uint8_array(uint8_t** array, int rows);
    void free_2d_int_array(int** array, int rows);
    int compare(const void* a, const void* b);
    void debug_display_int_array(int** array, struct dims* size);
    void debug_display_uint8_array(uint8_t** array, struct dims* size);
    int** hkr33_zigzag(struct dims* img_size, int K);
    struct window_edge* hkr33_strip(int** indices, int i, int K);
    uint8_t** hkr33_huang_medfilt2(uint8_t** img_pad, struct dims* img_pad_size, int K);

#endif