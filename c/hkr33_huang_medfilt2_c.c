#include "mex.h"
#include <stdint.h>
#include <stdlib.h>
#include "hkr33_huang_medfilt2.h"

// Helper function to allocate 2D uint8_t array
uint8_t** allocate_2d_uint8_array(struct dims* size) {
    uint8_t** array = (uint8_t**)malloc(size->M * sizeof(uint8_t*));
    for (int i = 0; i < size->M; i++) {
        array[i] = (uint8_t*)malloc(size->N * sizeof(uint8_t));
    }
    return array;
}

// Main MEX function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:mexFunction", "Two inputs required: image and K.");
    }

    if (!mxIsUint8(prhs[0])) {
        mexErrMsgIdAndTxt("MATLAB:mexFunction", "Input image must be of type uint8.");
    }

    if (!mxIsScalar(prhs[1]) || !mxIsDouble(prhs[1])) {
        mexErrMsgIdAndTxt("MATLAB:mexFunction", "Input K must be a scalar.");
    }

    // Define the dims structure
    struct dims img_pad_size;
    struct dims img_filt_size;

    // Get the input image and dimensions
    uint8_t *img_data = (uint8_t*)mxGetData(prhs[0]);

    img_pad_size.M = (int)(mxGetM(prhs[0]));
    img_pad_size.N = (int)(mxGetN(prhs[0]));

    // Copy input image data into a 2D array
    uint8_t** img_pad = allocate_2d_uint8_array(&img_pad_size);
    for (int i = 0; i < img_pad_size.M; i++) {
        for (int j = 0; j < img_pad_size.N; j++) {
            img_pad[i][j] = img_data[i + j * img_pad_size.M];
        }
    }

    // Get the value of K
    int K = (int)mxGetScalar(prhs[1]);

    int K_pad = K / 2;

    img_filt_size.M = img_pad_size.M - (K_pad * 2);
    img_filt_size.N = img_pad_size.N - (K_pad * 2);

    // Call the median filter function
    uint8_t** filtered_img = hkr33_huang_medfilt2(img_pad, &img_pad_size, K);

    // Create the output MATLAB array
    plhs[0] = mxCreateNumericMatrix(img_filt_size.M, img_filt_size.N, mxUINT8_CLASS, mxREAL);
    uint8_t *output_data = (uint8_t*)mxGetData(plhs[0]);

    // Copy filtered_img into the output MATLAB array
    for (int i = 0; i < img_filt_size.M; i++) {
        for (int j = 0; j < img_filt_size.N; j++) {
            output_data[i + (j * img_filt_size.M)] = filtered_img[i][j];
        }
    }

    // Free allocated memory
    free_2d_uint8_array(img_pad, img_pad_size.M);
    free_2d_uint8_array(filtered_img, img_filt_size.M);
}
