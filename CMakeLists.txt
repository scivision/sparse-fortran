cmake_minimum_required(VERSION 3.19...3.22)

project(SparseExamples
  LANGUAGES C Fortran)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

set(realbits 64)
set(arith "d")

option(autobuild "build missing libraries" true)

# --- default install directory under build/local
# users can specify like "cmake -B build -DCMAKE_INSTALL_PREFIX=~/mydir"
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # will not take effect without FORCE
  set(CMAKE_INSTALL_PREFIX ${PROJECT_BINARY_DIR} CACHE PATH "Install top-level directory" FORCE)
endif()

include(cmake/libraries.cmake)
include(cmake/mumps.cmake)

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

feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES)
