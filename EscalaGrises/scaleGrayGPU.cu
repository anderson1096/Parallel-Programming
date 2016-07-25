#include <bits/stdc++.h>
//incluyendo opencv, para el manejo de imagenes.

#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

//deifinicion global, ya que el opencv no maneja RGB, sino BGR (o sea al reves).
#define RED 2
#define GREEN 1
#define BLUE 0

//la imagen de salida no necesita los canales, ya que al ser en escala de grises, solo tiene un canal.
__host__
void imageToGray(unsigned char *imgInput, int width,int height, unsigned char *imgOutput){
    int row, col;
    for(row = 0; row < height; ++row){
      for(col = 0; col < width; ++col){
        imgOutput[row * width + col] = imgInput[(row * width + col)* 3 + RED]*0.299 + imgInput[(row * width + col)* 3 + GREEN]*0.587 + imgInput[(row * width + col)* 3 + BLUE]*0.114 ;
      }
    }

}

__global__
void imageToGrayGPU(unsigned char *imgInput, int width,int height, unsigned char *imgOutput){
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int row = blockIdx.y*blockDim.y + threadIdx.y;

    if(row < height && col < width)){
        imgOutput[row * width + col] = imgInput[(row * width + col)* 3 + RED]*0.299 + imgInput[(row * width + col)* 3 + GREEN]*0.587 + imgInput[(row * width + col)* 3 + BLUE]*0.114 ;
      }
    }

}

int main(int argc, char **argv){
  //defino mis imagenes
  cudaError_t error = cudaSuccess; // Para controlar errores
  unsigned char *h_imgInicial,*d_imgInicial, *h_imgGray,*d_imgGray, *h_imgGrises;
  char* imageName = argv[1];
  Mat img;

  img = imread(imageName,1);
  if(argc != 2 || img.empty()){
    printf("Error : Imagen no cargada\n");
    return -1;
  }

  //sacamos los atributos de la Imagen

  Size s = img.size();

  int width = s.width;
  int height = s.height;
  int sz = sizeof(unsigned char)*width*height*img.channels();
  int size = sizeof(unsigned char)*width*height;  //no multiplicamos, porque la imagen en escala de grises no tiene canales

  //Separando memoria para la imagen en el device y en la CPU

  h_imgInicial = (unsigned char *) malloc(sz);
  error = cudaMalloc((void**)&d_imgInicial,sz);
  if(error != cudaSuccess){
  	printf("Error  reservando memoria para d_imgInicial\n");
  	exit(-1);
  }

  //Pasando los datos de la imagen Leída

  h_imgInicial = img.data;
  //copiar los datos de la CPU al Device
  error = cudaMemcpy(d_imgInicial,h_imgInicial,sz,cudaMemcpyHostToDevice);
  if(error != cudaSuccess){
  	printf("Error copiando los datos de h_imgInicial a d_imgInicial\n");
  	exit(-1);
  }

  //separando memoria para las imagenes en grises en CPU y device

  imgGray = (unsigned char *) malloc(size);
  error = cudaMalloc((void**)&d_imgGray,size);
  if(error != cudaSuccess){
  	printf("Error  reservando memoria para d_imgGray\n");
  	exit(-1);
  } 

  //creamos las dimensiones de la malla para realizar la conversion a grises en la GPU
  dim3  dimBlock(32,32,1); //creando una dimension de 32 bloques, cada bloque con 32 hilos, 1024 hilos en total
  dim3  dimGrid(ceil(width/float(32)),ceil(height/float(32)),1);
  imageToGrayGPU <<dimGrid,dimBlock>>(d_imgInicial, width, height, d_imgGray);


  //Copiamos los resultados de la GPU en la CPU
  error = cudaMemcpy(h_imgGrises,d_imgGray,size,cudaMemcpyDeviceToHost);
  if(error != cudaSuccess){
  	printf("Error copiando de d_imgGray a h_imgGrises\n");
  	exit(-1);
  }

  //imageToGray(imgInicial,width,height,imgGray);

  Mat resultado_gray_imageCPU;
    resultado_gray_imageCPU.create(height,width,CV_8UC1);
    resultado_gray_imageCPU.data = h_imgGray;

   namedWindow("Grises", WINDOW_AUTOSIZE );
   imshow("Grises GPU", resultado_gray_imageCPU);

   waitKey(0);

  	cudaFree(d_imgGray); cudaFree(d_imgInicial);
   free(h_imgInicial);free(h_imgGray);
   free(h_imgGrises);
  

  return 0;
}

