cmake_minimum_required(VERSION 3.22...4.0)

project(SparseExamples
LANGUAGES C Fortran
)

enable_testing()

set(arith "d")

include(cmake/options.cmake)

find_package(MPI COMPONENTS C Fortran REQUIRED)

if(NOT DEFINED ENV{MKLROOT} AND NOT LAPACK_VENDOR MATCHES "^MKL")
  # oneMKL MKLConfig.cmake must be invoked only once
  find_package(LAPACK REQUIRED)
endif()

find_package(SCALAPACK REQUIRED)

find_package(MUMPS CONFIG)

find_package(METIS)

add_subdirectory(src)
