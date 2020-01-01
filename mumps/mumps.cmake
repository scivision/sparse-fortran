# MUMPS -- use cmake -DMUMPS_ROOT= for hint.
#
# Intel MKL-compiled MUMPS requires at the linker for the main executable:
# mkl_scalapack_lp64 mkl_blacs_intelmpi_lp64 mkl_intel_lp64 mkl_intel_thread mkl_core
#
# easily obtain MUMPS without compiling:
# CentOS 6/7 EPEL: yum install mumps-devel
# Ubuntu / Debian: apt install libmumps-dev

unset(_mumps_extra)

if(BLACS_ROOT)
  find_package(BLACS REQUIRED)
  list(APPEND _mumps_extra ${BLACS_LIBRARIES})
endif()

if(metis OR metis IN_LIST ordering)
  find_package(METIS REQUIRED)
  list(APPEND _mumps_extra ${METIS_LIBRARIES})
endif()

if(scotch OR scotch IN_LIST ordering)
  find_package(Scotch REQUIRED COMPONENTS ESMUMPS)
  list(APPEND _mumps_extra ${Scotch_LIBRARIES})
endif()

find_package(SCALAPACK)
if(NOT SCALAPACK_FOUND)
  message(STATUS "SKIP: MUMPS due to missing scalapack")
endif()

find_package(LAPACK)
if(NOT LAPACK_FOUND)
  message(STATUS "SKIP: MUMPS due to missing lapack")
endif()

# -- MUMPS
if(NOT arith)
  if(realbits EQUAL 32)
    set(arith s)
  else()
    set(arith d)
  endif()
endif()

find_package(MUMPS COMPONENTS ${arith})
if(NOT MUMPS_FOUND)
  return()
endif()


# -- minimal check that MUMPS is linkable
include(CheckFortranSourceCompiles)

set(CMAKE_REQUIRED_LIBRARIES ${MUMPS_LIBRARIES} ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES} MPI::MPI_Fortran)
set(CMAKE_REQUIRED_INCLUDES ${MUMPS_INCLUDE_DIRS} ${SCALPAACK_INCLUDE_DIRS})

check_fortran_source_compiles("include '${arith}mumps_struc.h'
type(${arith}mumps_struc) :: mumps_par
end"
  MUMPS_OK SRC_EXT f90)

if(NOT MUMPS_OK)
  set(MUMPS_FOUND false PARENT_SCOPE)
  return()
endif()
