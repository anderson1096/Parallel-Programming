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

void imageToGray(unsigned char *imgInput, int width,int height, unsigned char *imgOutput){
    int row, col;
    for(row = 0; row < height; ++row){
      for(col = 0; col < width; ++col){
        imgOutput[row * width + col] = imgInput[(row * width + col)* 3 + RED]*0.299 + imgInput[(row * width + col)* 3 + GREEN]*0.587 + imgInput[(row * width + col)* 3 + BLUE]*0.114 ;
      }
    }

}

int main(int argc, char **argv){
  //defino mis imagenes

  unsigned char *imgInicial, *imgGray, *imgGrises;
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

  imgInicial = (unsigned char *) malloc(sz);
  imgInicial = img.data;

  imgGray = (unsigned char *) malloc(size);

  imageToGray(imgInicial,width,height,imgGray);

  Mat resultado_gray_imageCPU;
    resultado_gray_imageCPU.create(height,width,CV_8UC1);
    resultado_gray_imageCPU.data = imgGray;

  /*
    free(imgInicial);
    free(imgGray);
  */
   namedWindow("Melo", WINDOW_AUTOSIZE );
   imshow("Melo", resultado_gray_imageCPU);

   waitKey(0);

  return 0;
}
