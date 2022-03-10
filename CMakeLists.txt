cmake_minimum_required(VERSION 3.20...3.23)

project(SparseExamples
LANGUAGES C Fortran
)

enable_testing()

set(realbits 64)
set(arith "d")

include(cmake/options.cmake)

find_package(MPI COMPONENTS C Fortran REQUIRED)
find_package(LAPACK REQUIRED)
find_package(SCALAPACK REQUIRED)
find_package(MUMPS)
find_package(METIS)

add_subdirectory(src)
