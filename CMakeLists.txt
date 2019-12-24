cmake_minimum_required(VERSION 3.12)
project(Sparse
  LANGUAGES C Fortran)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

if(NOT realbits)
  set(realbits 64)
endif()

find_package(MPI COMPONENTS Fortran REQUIRED)
find_package(LAPACK REQUIRED)
find_package(SCALAPACK)
find_package(METIS)

add_subdirectory(src)
add_subdirectory(mumps)
add_subdirectory(pardiso)