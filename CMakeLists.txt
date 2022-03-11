cmake_minimum_required(VERSION 3.20...3.23)

project(SparseExamples
LANGUAGES C Fortran
)

enable_testing()

set(arith "d")

include(cmake/options.cmake)

add_compile_options(
$<$<AND:$<CONFIG:Release>,$<COMPILE_LANG_AND_ID:Fortran,GNU>>:-fno-backtrace>
)

find_package(MPI COMPONENTS C Fortran REQUIRED)
find_package(LAPACK REQUIRED)
find_package(SCALAPACK REQUIRED)
find_package(MUMPS)
find_package(METIS)

add_subdirectory(src)
