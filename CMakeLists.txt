cmake_minimum_required(VERSION 3.12)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(SparseExamples
  LANGUAGES C Fortran)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

if(NOT realbits)
  set(realbits 64)
endif()

find_package(MPI COMPONENTS Fortran REQUIRED)
find_package(OpenMP COMPONENTS C Fortran)
find_package(LAPACK REQUIRED)
find_package(SCALAPACK)

add_subdirectory(src)
add_subdirectory(mumps)
add_subdirectory(pardiso)