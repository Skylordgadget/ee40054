#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h> 

int** pad_image_with_zeros(int** image, int width, int height, int filter_size) {
    int padding = filter_size / 2; // Amount of padding needed on each side

    // Dimensions of the padded image
    int padded_width = width + 2 * padding;
    int padded_height = height + 2 * padding;

    // Allocate memory for the padded image
    int** padded_image = (int**)malloc(padded_height * sizeof(int*));
    for (int i = 0; i < padded_height; i++) {
        padded_image[i] = (int*)calloc(padded_width, sizeof(int));
    }

    // Copy the original image data into the center of the padded image
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            padded_image[i + padding][j + padding] = image[i][j];
        }
    }

    return padded_image;
}

unsigned char ** fastMedianC(int **pad_img, int filter_size, int image_rows, int image_cols) {
    int threshold = (filter_size * filter_size) / 2;
    int *hist = (int *)calloc(256, sizeof(int));  // Histogram with 256 bins for 8-bit image
    unsigned char **filtered_image = (unsigned char **)malloc(image_rows * sizeof(unsigned char *));
    int ltmdn = 0;
    unsigned char filtWindow[filter_size * filter_size];
    int k;
    int mdn = 0;
    int cum_sum = 0;
    int pixel_val;

    for (int i = 0; i < image_rows; i++) {
        filtered_image[i] = (unsigned char *)calloc(image_cols, sizeof(unsigned char));
    }

    for (int row = 0; row < image_rows; row++) {
        for (int col = 0; col < image_cols - 1; col++) {

            // Extract the Window
            k=0;
            if ((col+filter_size) > 159) {
                printf("DEATH");
            }
            for (int i = row; i < row + filter_size; i++) {
                for (int j = col; j < col + filter_size; j++) {
                    filtWindow[k++] = pad_img[i][j];
                }
            }            


            if (col == 0) {
                // Initialize the histogram with the first filter window
                for (int i = 0; i < filter_size; i++) {
                    for (int j = 0; j < filter_size; j++) {
                        int pixel_val = pad_img[row + i][col + j];
                        hist[pixel_val]++;
                    }
                }

                // Find initial median
                while (cum_sum < threshold) {
                    cum_sum += hist[mdn];
                    mdn++;
                }
                mdn--;
                
                for (int i = 0; i < filter_size*filter_size; i++) {
                    if (filtWindow[i] < mdn) {
                        (ltmdn)++;
                    }
                }

                // Store initial median in filtered image
                filtered_image[row][0] = mdn;
            }

            // Remove old pixels from the histogram
            if (col <= image_cols && row <= image_rows) {
                for (int i = row; i < row + filter_size; i++) {
                    pixel_val = pad_img[i][col];
                    // Check pixel removed was less than the median
                    if (pixel_val < mdn){
                        ltmdn--;
                    }
                    hist[pixel_val]--;
                }
            }

            // Add new pixels to the histogram
            if (col+(filter_size/2) < image_cols && row+(filter_size/2) <= image_rows) {
                for (int i = row; i < row + filter_size; i++) {
                    pixel_val = pad_img[i][col + filter_size];
                    // Check if pixel being added is less than the median
                    if (pixel_val < mdn){
                        ltmdn++;
                    }
                    hist[pixel_val]++;
                }
            }

            // Adjust median based on histogram
            mdn = filtered_image[row][col];
            if (ltmdn > threshold) {
                while (ltmdn > threshold) {
                    mdn--;
                    ltmdn -= hist[mdn];
                }
            } else {
                while (ltmdn + hist[mdn] <= threshold) {
                    ltmdn += hist[mdn];
                    mdn++;
                }
            }

            // Update filtered image
            filtered_image[row][col + 1] = mdn;
        }
    }

    free(hist);
    return filtered_image;  
}

struct header {
	int rows;
	int cols;
};

/******************************* Global Variables ****************************/
int **pad_img;

int fread_header(FILE *fp, struct header *hd);
void error(char *msg);
int getline_aux(FILE *file, char *buffer, unsigned int n);

/******************************* Main Program *******************************/
int main(int argc, char *argv[]) {
    FILE *infile;
    struct header hd1;
    int i, j;

    if (argc < 2) {
        printf("Usage: main infile\n");
        exit(0);
    }

    printf("%s",argv[1]);

    // Open the input file
    infile = fopen(argv[1], "rb");
    if (infile == NULL) {
        printf("Can't open input file.\n");
        exit(0);
    }

    // Read the header to get image dimensions
    hd1.rows=256;
    hd1.cols=159;

    // Allocate memory for the image
    pad_img = (int **)malloc(sizeof(int *) * hd1.rows);
    for (i = 0; i < hd1.rows; i++) {
        pad_img[i] = malloc(hd1.cols * sizeof(int));
    }

    // Read pixel data into pad_img
    for (i = 0; i < hd1.rows; i++) {
        for (j = 0; j < hd1.cols; j++) {
            pad_img[i][j] = getc(infile);
        }
    }

    unsigned char **filtered_image = (unsigned char **)malloc(hd1.rows * sizeof(unsigned char *));
    int filter_size=3;
    int padding = 1;
    // PAD
    pad_img=pad_image_with_zeros(pad_img,hd1.cols,hd1.rows,filter_size);

    // FILTERING
    filtered_image=fastMedianC(pad_img,filter_size,hd1.rows+2,hd1.cols+2);
    
    // Free the allocated memory
    for (i = 0; i < hd1.rows; i++) {
        free(pad_img[i]);
        free(filtered_image);
    }
    free(pad_img);

    // Close the input file
    fclose(infile);

    return 0;
}

int getline_aux (FILE *file, char *buffer, unsigned int n)
{
  int reading = 0;
  while (!reading) {
  if (!fgets (buffer, n, file))
    reading = (buffer [0] != '#');
    return 0;
  }
 return 1;
}


void error(char *msg)
{
  fprintf(stderr, "error in %s\n",msg);
  exit(-1);
}


int fread_header(FILE * fp, struct header * hd)
{
  int maxgray;
  char buf2[3];
  char buf[256];
  if (!getline_aux (fp, buf, 256) || (sscanf(buf, "%s", buf2) != 1))
		error("fread_header: first line");

  if (strcmp(buf2,"P5") !=0)
		 error("fread_header: Not a raw PGM file");

  if (!getline_aux (fp, buf, 256) || (sscanf(buf, "%d %d",
  &(hd->cols),&(hd->rows)) != 2))
		error("fread_header: couldn't read X Y");

  if (!getline_aux (fp, buf, 256) || (sscanf(buf, "%d", &maxgray) != 1))
		 error("fread_header: couldn't read maxgray");

  if (maxgray > 255)
		error("fread_header: maxgray > 255");

  return 1;
}

int fwrite_header(FILE * fp, struct header * hd)
{
	fprintf(fp,"%s\n","P5");
	fprintf(fp,"%d %d\n", hd->cols, hd->rows);
	fprintf(fp,"%d\n",255);
	return(0);
}