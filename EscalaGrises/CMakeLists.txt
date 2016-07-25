cmake_minimum_required(VERSION 2.8)
project( Escala-Grises )
find_package( OpenCV REQUIRED )
add_executable( Escala-Grises Escala-Grises.cpp )
target_link_libraries( Escala-Grises ${OpenCV_LIBS} )

