#include <mex.h>
#include <string.h>
#include <stdio.h>
#include <hkr33_huang_medfilt2.h>

uint8_t **flat_to_double_pointer(uint8_t *array, struct dims *size) {
    uint8_t **array2D = (uint8_t **)mxMalloc(size->M * sizeof(uint8_t *));
    for (mwSize i = 0; i < size->M; i++) {
        array2D[i] = array + i * size->N;  // Each row pointer points to the start of each row
    }
    return array2D;
}

uint8_t *double_pointer_to_flat(uint8_t **array2D, struct dims *size) {
    uint8_t *array = (uint8_t *)mxMalloc(size->M * size->N * sizeof(uint8_t));
    
    for (mwSize i = 0; i < size->M; i++) {
        for (mwSize j = 0; j < size->N; j++) {
            array[i * size->N + j] = array2D[i][j];  // Copy each element to the flat array
        }
    }
    return array;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MyToolbox:arrayResize:nrhs", "One input required.");
    }

    if (!mxIsUint8(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MyToolbox:arrayResize:notUint8", "Input image must be type uint8.");
    }
    if (!mxIsInt32(prhs[1]) || mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt("MyToolbox:arrayResize:notInt32", "Window size must be type integer.");
    }


    struct dims img_pad_size;
    struct dims img_filt_size;

    uint8_t *img_pad = (uint8_t *)mxGetData(prhs[0]);
    img_pad_size.M = mxGetM(prhs[0]);
    img_pad_size.N = mxGetN(prhs[0]);

    int K = (int)mxGetScalar(prhs[1]);

    int K_pad = K / 2;
    img_filt_size.M = img_pad_size.M - (K_pad * 2); 
    img_filt_size.N = img_pad_size.N - (K_pad * 2);

    uint8_t **img_pad_2d = flat_to_double_pointer(img_pad,&img_pad_size);

    uint8_t **img_filt = hkr33_huang_medfilt2(img_pad_2d,&img_pad_size,K);

    debug_display_uint8_array(img_pad_2d,&img_pad_size);
    debug_display_uint8_array(img_filt,&img_filt_size);

    uint8_t *img_filt_flat = double_pointer_to_flat(img_pad_2d,&img_pad_size);

    plhs[0] = mxCreateNumericMatrix(img_filt_size.M, img_filt_size.N, mxUINT8_CLASS, mxREAL);
    uint8_t *img_out = (uint8_t *)mxGetData(plhs[0]);
    memcpy(img_out, img_filt_flat, img_filt_size.M * img_filt_size.N * sizeof(uint8_t));

    mxFree(img_filt);
    mxFree(img_pad_2d);
    mxFree(img_filt_flat);
}