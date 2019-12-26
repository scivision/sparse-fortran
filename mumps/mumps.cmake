# MUMPS -- use cmake -DMUMPS_ROOT= for hint.
#
# Intel MKL-compiled MUMPS requires at the linker for the main executable:
# mkl_scalapack_lp64 mkl_blacs_intelmpi_lp64 mkl_intel_lp64 mkl_intel_thread mkl_core
#
# easily obtain MUMPS without compiling:
# CentOS 6/7 EPEL: yum install mumps-devel
# Ubuntu / Debian: apt install libmumps-dev

if(LIB_DIR)
  set(MUMPS_ROOT ${LIB_DIR}/MUMPS)
endif()

if(BLACS_ROOT)
  find_package(BLACS)
  if(BLACS_FOUND)
    list(APPEND SCALAPACK_LIBRARIES ${BLACS_LIBRARIES})
  endif()
endif()


# Mumps
if(NOT arith)
  if(realbits EQUAL 32)
    set(arith s)
  else()
    set(arith d)
  endif()
endif()

# find_package(MUMPS COMPONENTS ${arith})
if(NOT MUMPS_FOUND)
  return()
endif()

# -- optional -- PORD is always used.
if(Scotch_ROOT)
  find_package(Scotch COMPONENTS ESMUMPS)
  if(Scotch_FOUND)
    list(APPEND MUMPS_LIBRARIES ${Scotch_LIBRARIES})
  endif()
endif()

if(METIS_ROOT)
  find_package(METIS)
  if(METIS_FOUND)
    list(APPEND MUMPS_LIBRARIES ${METIS_LIBRARIES})
  endif()
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
