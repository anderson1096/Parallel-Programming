cmake_minimum_required(VERSION 2.8)
project( Sobel_CPU )
find_package( OpenCV REQUIRED )


add_executable( Sobel_CPU Sobel_CPU.cpp )
target_link_libraries( Sobel_CPU ${OpenCV_LIBS} )
