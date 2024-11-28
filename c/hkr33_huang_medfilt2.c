#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <hkr33_huang_medfilt2.h>
#include "mex.h"

// free 2D uint8 arrays
void free_2d_uint8_array(uint8_t** array, int rows) {
    for (int i = 0; i < rows; i++) {
        free(array[i]); // free each row
    }
    free(array); // free the array itself
}

// free 2D int arrays
void free_2d_int_array(int** array, int rows) {
    for (int i = 0; i < rows; i++) {
        free(array[i]); // free each row
    }
    free(array); // free the array itself
}

// compare two uint8 values (used by qsort)
int compare(const void* a, const void* b) {
    return (*(uint8_t*)a - *(uint8_t*)b);
}

// debug function to display a 2D int array (not used by MATLAB)
void debug_display_int_array(int** array, struct dims* size) {
    for (int i = 0; i < size->M; i++) { 
        for (int j = 0; j < size->N; j++) printf("%d ", array[i][j]); // print each value
        printf("\n");
    }
    printf("\n");
}

// debug function to display a 2D uint8 array (not used by MATLAB)
void debug_display_uint8_array(uint8_t** array, struct dims* size) {
    for (int i = 0; i < size->M; i++) { 
        for (int j = 0; j < size->N; j++) printf("%d ", array[i][j]); // print each value
        printf("\n");
    }
    printf("\n");
}

// generate a zigzag order for traversing pixels
int** hkr33_zigzag(struct dims* img_size, int K) {
    struct dims indices_size;
    int K_pad = K / 2;

    // size of the indices array is determined by image size and kernel padding
    indices_size.M = ((img_size->M - (K_pad * 2)) * (img_size->N - (K_pad * 2))); 
    indices_size.N = 2;

    // allocate memory for indices
    int** indices = (int**) malloc(indices_size.M * sizeof(int*));
    for (int i = 0; i < indices_size.M; i++) {
        indices[i] = (int*) malloc(indices_size.N * sizeof(int));
    }

    int cnt = 0, row = 0;
    // generate zigzag pattern across rows
    for (int i = K_pad; i < img_size->M - K_pad; i++) {
        if (row % 2 == 0) { // for even rows, go left to right
            for (int j = K_pad; j < img_size->N - K_pad; j++) {
                indices[cnt][0] = i; indices[cnt][1] = j;  
                cnt++;
            }
        } else { // for odd rows, go right to left
            for (int j = img_size->N - K_pad - 1; j > K_pad - 1; j--) {
                indices[cnt][0] = i; indices[cnt][1] = j;  
                cnt++;
            }
        }
        row++;
    }

    return indices;
}

// calculate new and old edge indices for a moving window
struct window_edge* hkr33_strip(int** indices, int i, int K) {
    struct window_edge* edge = malloc(sizeof(struct window_edge));
    int y = indices[i][0], x = indices[i][1];
    int prev_y = indices[i-1][0], prev_x = indices[i-1][1];

    int dir_y = y - prev_y, dir_x = x - prev_x;
    int K_pad = K / 2;

    struct dims edge_size;
    edge_size.M = K; edge_size.N = 2;

    // allocate memory for edge arrays
    edge->n = (int**) malloc(edge_size.M * sizeof(int*));
    edge->o = (int**) malloc(edge_size.M * sizeof(int*));
    for (int j = 0; j < edge_size.M; j++) {
        edge->n[j] = (int*) malloc(edge_size.N * sizeof(int));
        edge->o[j] = (int*) malloc(edge_size.N * sizeof(int));
    }

    int cnt = 0;
    // calculate edge indices based on window movement direction
    if (dir_y == 0) { // horizontal movement
        for (int yy = y - K_pad; yy <= y + K_pad; yy++) {
            edge->o[cnt][0] = yy; edge->o[cnt][1] = x - dir_x * (K_pad + 1);
            edge->n[cnt][0] = yy; edge->n[cnt][1] = x + dir_x * K_pad;
            cnt++;
        }
    } else { // vertical movement
        for (int xx = x - K_pad; xx <= x + K_pad; xx++) {
            edge->o[cnt][0] = y - dir_y * (K_pad + 1); edge->o[cnt][1] = xx;
            edge->n[cnt][0] = y + dir_y * K_pad; edge->n[cnt][1] = xx;
            cnt++;
        }
    }

    return edge;
}

// perform Huang's median filtering
uint8_t** hkr33_huang_medfilt2(uint8_t** img_pad, struct dims* img_pad_size, int K) {
    int M_pad = img_pad_size->M, N_pad = img_pad_size->N;
    int K_pad = K / 2, M = M_pad - (K_pad * 2), N = N_pad - (K_pad * 2);
    const int h = 256; // intensity levels for an 8-bit image
    uint8_t window[K * K]; // store values within the window
    int histogram[h];
    for (int i = 0; i < h; i++) {
        histogram[i] = 0; // initialise histogram
    }


    // allocate memory for filtered image
    uint8_t** filtered_img = (uint8_t**) malloc(M * sizeof(uint8_t*));
    for (int i = 0; i < M; i++) {
        filtered_img[i] = (uint8_t*) malloc(N * sizeof(uint8_t));
    }

    // initialise the first window
    int cnt = 0;
    for (int y = 0; y < K; y++) {
        for (int x = 0; x < K; x++) {
            window[cnt] = img_pad[y][x];
            histogram[img_pad[y][x]]++;
            cnt++;
        }
    }

    qsort(window, cnt, sizeof(uint8_t), compare); // sort window values
    int th = (K * K) / 2; // threshold for median
    uint8_t mdn = window[th]; // find initial median
    int ltmdn = 0; // count of values less than median

    for (int y = 0; y < K; y++) {
        for (int x = 0; x < K; x++) {
            if (img_pad[y][x] < mdn) ltmdn++;
        }
    }

    filtered_img[0][0] = mdn; // set median for the first pixel

    // generate zigzag traversal order
    int** indices = hkr33_zigzag(img_pad_size, K);

    struct window_edge* edge;
    // process remaining pixels
    for (int i = 1; i < M * N; i++) {
        int y = indices[i][0], x = indices[i][1];
        edge = hkr33_strip(indices, i, K); // get new and old edge pixels

        // update histogram and median
        for (int j = 0; j < K; j++) {
            int yy = edge->o[j][0], xx = edge->o[j][1];
            histogram[img_pad[yy][xx]]--;
            if (img_pad[yy][xx] < mdn) ltmdn--;

            yy = edge->n[j][0]; xx = edge->n[j][1];
            histogram[img_pad[yy][xx]]++;
            if (img_pad[yy][xx] < mdn) ltmdn++;
        }

        // adjust median dynamically
        if (ltmdn > th) {
            while (ltmdn > th) {
                mdn--; ltmdn -= histogram[mdn];
            }
        } else {
            while ((ltmdn + histogram[mdn]) <= th) {
                ltmdn += histogram[mdn]; mdn++;
            }
        }
        filtered_img[y - K_pad][x - K_pad] = mdn;
    }

    // clean up memory
    free_2d_int_array(indices, M * N);
    free_2d_int_array(edge->n, K);
    free_2d_int_array(edge->o, K);

    return filtered_img;
}
