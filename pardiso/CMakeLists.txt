cmake_minimum_required(VERSION 3.14)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(PardisoExamples
  LANGUAGES C Fortran)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)

if(NOT DEFINED MKLROOT AND NOT DEFINED ENV{MKLROOT})
  message(STATUS "SKIP: Pardiso")
  set(pardiso false)
  return()
else()
  set(pardiso true)
endif()

find_package(LAPACK COMPONENTS MKL REQUIRED)
find_package(SCALAPACK COMPONENTS MKL REQUIRED)

add_executable(pardiso_basic pardiso_basic.f90)
target_link_libraries(pardiso_basic PRIVATE SCALAPACK::SCALAPACK LAPACK::LAPACK)
add_test(NAME pardisoBasic COMMAND pardiso_basic)
