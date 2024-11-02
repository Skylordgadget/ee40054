#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

struct dims
{
    int M;
    int N;  
};

struct window_edge 
{
    uint8_t** old;
    uint8_t** new;
};

void free_2d_uint8_array(uint8_t** array, int rows) {
    for (int i = 0; i < rows; i++) {
        free(array[i]);
    }
    free(array);
}

void free_2d_int_array(int** array, int rows) {
    for (int i = 0; i < rows; i++) {
        free(array[i]);
    }
    free(array);
}


int compare(const void* a, const void* b) {
    return (*(uint8_t*)a - *(uint8_t*)b);
}


void debug_display_int_array(int** array, struct dims* size) {
    for (int i=0; i<size->M; i++) { 
        for (int j=0; j<size->N; j++) printf("%d ", array[i][j]);
        printf("\n");
    }
    printf("\n");
}

void debug_display_uint8_array(uint8_t** array, struct dims* size) {
    for (int i=0; i<size->M; i++) { 
        for (int j=0; j<size->N; j++) printf("%d ", array[i][j]);
        printf("\n");
    }
    printf("\n");
}

int** hkr33_zigzag(struct dims* img_size, int K) {
    struct dims indices_size;
    int K_pad = K / 2;
    indices_size.M = ((img_size->M - (K_pad * 2)) * (img_size->N - (K_pad * 2))); indices_size.N = 2;
    
    int** indices = (int**) malloc(indices_size.M * sizeof(int*));
    for (int i = 0; i < indices_size.M; i++) {
        indices[i] = (int*) malloc(indices_size.N * sizeof(int));
    }


    
    int j_start, j_stop, j_delta;
    int cnt = 0;
    int row = 0;
    for (int i = K_pad; i < img_size->M - K_pad; i++) {

        if (row%2==0) { 
            for (int j = K_pad; j < img_size->N - K_pad; j++) {
                indices[cnt][0] = i; indices[cnt][1] = j;  
                cnt++;
            }
        } 
        else { 
            for (int j = img_size->N - K_pad - 1; j > K_pad - 1; j--) {
                indices[cnt][0] = i; indices[cnt][1] = j;  
                cnt++;
            }
        }
        row++;
    }


    debug_display_int_array(indices,&indices_size);

    return indices;
}

 
struct window_edge* hkr33_strip(int** indices, int i, int K) {
    struct window_edge* edge;
    edge = malloc(sizeof(struct window_edge));
    int y = indices[i][0]; int x = indices[i][1];
    int prev_y = indices[i-1][0]; int prev_x = indices[i-1][1];

    int dir_y = y-prev_y; int dir_x = x-prev_x;
    int K_pad = K / 2;
    
    struct dims edge_size;
    edge_size.M = K; edge_size.N = 2;
    edge->new = (uint8_t**) malloc(edge_size.M * sizeof(uint8_t*));
    for (int j = 0; j < edge_size.M; j++) {
        edge->new[j] = (uint8_t*) malloc(edge_size.N * sizeof(uint8_t));
    }

    edge->old = (uint8_t**) malloc(edge_size.M * sizeof(uint8_t*));
    for (int j = 0; j < edge_size.M; j++) {
        edge->old[j] = (uint8_t*) malloc(edge_size.N * sizeof(uint8_t));
    }

    int cnt = 0;

    if (dir_y == 0) {
        for (int yy = y-K_pad; yy < y+K_pad+1; yy++) {
            edge->old[cnt][0] = yy; edge->old[cnt][1] = x - dir_x * (K_pad+1);
            edge->new[cnt][0] = yy; edge->new[cnt][1] = x + dir_x * K_pad;
            cnt++;
        }
    } else {
        for (int xx = x-K_pad; xx < x+K_pad+1; xx++) {
            edge->old[cnt][0] = y - dir_y * (K_pad+1); edge->old[cnt][1] = xx;
            edge->new[cnt][0] = y + dir_y * K_pad; edge->new[cnt][1] = xx;
            cnt++;
        }
    }

    return edge;
}

uint8_t** hkr33_huang_medfilt2(uint8_t** img_pad, struct dims* img_pad_size, int K) {
    int M_pad = img_pad_size->M; int N_pad = img_pad_size->N;
    int K_pad = K / 2;
    int M = M_pad - (K_pad * 2); int N = N_pad - (K_pad * 2);
    const int h = 256;
    uint8_t window[K*K];
    uint8_t histogram[h];
    for (int i = 0; i < h; i++) {
        histogram[i] = 0;
    }

    uint8_t** filtered_img = (uint8_t**) malloc(M * sizeof(uint8_t*));
    for (int i = 0; i < M; i++) {
        filtered_img[i] = (uint8_t*) malloc(N * sizeof(uint8_t));
    }

    int cnt = 0;
    for (int y = 0; y < K; y++) {
        for (int x = 0; x < K; x++) {
            window[cnt] = img_pad[y][x];
            histogram[img_pad[y][x]]++;
            cnt++;
        }
    }

    qsort(window,cnt,sizeof(uint8_t),compare);
    uint8_t th = (K*K) / 2;
    uint8_t mdn = window[th];
    uint8_t ltmdn = 0;

    for (int y = 0; y < K; y++) {
        for (int x = 0; x < K; x++) {
            if (img_pad[y][x] < mdn) {ltmdn++;}
        }
    }

    filtered_img[0][0] = mdn;

    int** indices = hkr33_zigzag(img_pad_size, K);

    struct window_edge* edge;

    for (int i = 1; i < (M*N); i++) {
        int y = indices[i][0]; int x = indices[i][1];

        edge = hkr33_strip(indices,i,K);

        for (int j = 0; j < K; j++) {
            int yy = edge->old[j][0]; int xx = edge->old[j][1];
            histogram[img_pad[yy][xx]]--;
            if (img_pad[yy][xx] < mdn) {ltmdn--;}

            yy = edge->new[j][0]; xx = edge->new[j][1];
            histogram[img_pad[yy][xx]]++;
            if (img_pad[yy][xx] < mdn) {ltmdn++;}
        }

        if (ltmdn > th) {
            while (ltmdn > th) {
                mdn--; ltmdn = ltmdn - histogram[mdn];
            }
        } else {
            while ((ltmdn + histogram[mdn]) <= th) {
                ltmdn = ltmdn + histogram[mdn]; mdn++;
            }
        }
        filtered_img[y-K_pad][x-K_pad] = mdn;
    }

    return filtered_img;

    free_2d_int_array(indices,(M*N));
    free_2d_uint8_array(edge->new,K);
    free_2d_uint8_array(edge->old,K);
}



int main () {
    struct dims img_pad_size;
    img_pad_size.M = 11; img_pad_size.N = 11;

    struct dims img_filt_size;
    img_filt_size.M = 9; img_filt_size.N = 9;

    uint8_t** img_pad = (uint8_t**) malloc(img_pad_size.M * sizeof(uint8_t*));
    for (int i = 0; i < img_pad_size.M; i++) {
        img_pad[i] = (uint8_t*) malloc(img_pad_size.N * sizeof(uint8_t));
    }

    uint8_t** img_filt = (uint8_t**) malloc(img_filt_size.M * sizeof(uint8_t*));
    for (int i = 0; i < img_filt_size.M; i++) {
        img_filt[i] = (uint8_t*) malloc(img_filt_size.N * sizeof(uint8_t));
    }    
    

    for (int i = 0; i < img_pad_size.M; i++) {
        for (int j = 0; j < img_pad_size.N; j++) {
            if (((i > 0) && (i < 4)) && ((j > 0) && (j < 4))) {
                img_pad[i][j] = 0xFF;
            } else {
                img_pad[i][j] = 0x00;
            }
        }
    }
    
    img_filt = hkr33_huang_medfilt2(img_pad,&img_pad_size,3);

    debug_display_uint8_array(img_pad,&img_pad_size);
    debug_display_uint8_array(img_filt,&img_filt_size);
    printf("\n\n");
    free_2d_uint8_array(img_pad,img_pad_size.M);
    free_2d_uint8_array(img_filt,img_filt_size.M);
}

