# MUMPS -- use cmake -DMUMPS_ROOT= for hint.
#
# Intel MKL-compiled MUMPS requires at the linker for the main executable:
# mkl_scalapack_lp64 mkl_blacs_intelmpi_lp64 mkl_intel_lp64 mkl_intel_thread mkl_core
#
# easily obtain MUMPS without compiling:
# CentOS 6/7 EPEL: yum install mumps-devel
# Ubuntu / Debian: apt install libmumps-dev

# --- prereqs
include(${CMAKE_CURRENT_LIST_DIR}/lapack.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/scalapack.cmake)

# --- MUMPS

if(mumps_external)
  include(${CMAKE_CURRENT_LIST_DIR}/mumps_external.cmake)
  return()
endif()

unset(_mumps_extra)

if(MUMPS_ROOT OR (DEFINED ENV{MUMPS_ROOT}) OR (CMAKE_Fortran_COMPILER_ID STREQUAL GNU))
  if(autobuild)
    find_package(MUMPS COMPONENTS ${arith})
  else()
    find_package(MUMPS COMPONENTS ${arith} REQUIRED)
  endif()
else()
  message(VERBOSE "Skipping find_package(MUMPS)")
endif()

if(MUMPS_FOUND)
  set(mumps_external false CACHE BOOL "autobuild Mumps")
else()
  include(${CMAKE_CURRENT_LIST_DIR}/mumps_external.cmake)
  return()
endif()

if(metis)
  find_package(METIS REQUIRED)
  list(APPEND _mumps_extra METIS::METIS)
endif()

if(scotch)
  find_package(Scotch REQUIRED COMPONENTS ESMUMPS)
  list(APPEND _mumps_extra Scotch::Scotch)
endif()
# rather than appending libraries everywhere, just put them together here.
list(APPEND MUMPS_LIBRARIES SCALAPACK::SCALAPACK LAPACK::LAPACK ${_mumps_extra})
if(OpenMP_FOUND)
  list(APPEND MUMPS_LIBRARIES OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
endif()
