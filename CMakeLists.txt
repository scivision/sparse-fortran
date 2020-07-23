cmake_minimum_required(VERSION 3.14)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(SparseExamples
  LANGUAGES C Fortran)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

set(realbits 64)
set(arith "d")

option(autobuild "build missing libraries" OFF)

find_package(MPI COMPONENTS Fortran REQUIRED)

add_subdirectory(src)
add_subdirectory(mumps)
add_subdirectory(pardiso)

# ---

include(FeatureSummary)

set_package_properties(MPI PROPERTIES URL "https://www.open-mpi.org/")
set_package_properties(LAPACK PROPERTIES URL "https://github.com/Reference-LAPACK/lapack")
set_package_properties(SCALAPACK PROPERTIES URL "https://github.com/Reference-ScaLAPACK/scalapack")
set_package_properties(MUMPS PROPERTIES URL "http://mumps-solver.org/")

add_feature_info(PARDISO pardiso "PARDISO Direct Sparse Solver")

feature_summary(WHAT ALL)
