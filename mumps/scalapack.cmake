find_package(SCALAPACK)
find_package(LAPACK REQUIRED)

if(SCALAPACK_FOUND)
  set(scalapack_external false)
else()
  set(scalapack_external true)
  include(${CMAKE_CURRENT_LIST_DIR}/scalapack_external.cmake)
  return()
endif()
# -- verify Scalapack links

set(CMAKE_REQUIRED_INCLUDES ${SCALAPACK_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES} MPI::MPI_Fortran)
# MPI needed for ifort

set(_code "
implicit none

integer :: ictxt, myid, nprocs, mycol, myrow, npcol, nprow
real :: eps
real, external :: pslamch

! arbitrary test parameters
npcol = 2
nprow = 2

call blacs_pinfo(myid, nprocs)
call blacs_get(-1, 0, ictxt)
call blacs_gridinit(ictxt, 'C', nprocs, 1)

call blacs_gridinfo(ictxt, nprow, npcol, myrow, mycol)

eps = pslamch(ictxt, 'E')

if(myrow == mycol) print '(A, F10.6)', 'OK: Scalapack Fortran  eps=', eps

call blacs_gridexit(ictxt)
call blacs_exit(0)

end program")

check_fortran_source_compiles(${_code} SCALAPACK_Compiles_OK SRC_EXT f90)
if(NOT SCALAPACK_Compiles_OK)
message(FATAL_ERROR "Scalapack ${SCALAPACK_LIBRARIES} not building with LAPACK ${LAPACK_LIBRARIES} and ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
endif()

# FIXME: figure out SCALAPACK_Runs_OK with non-default libgfortran.so
# as this test fails in that case. Is it an issue with LD_LIBRARY_PATH?
# if so, may be able to pass via CMAKE_REQUIRED_LINK_OPTIONS of check_fortran_source_runs()
# to underlying try_run() link_options. This would have to be tested on a system where
# this check currently fails, such as one using a non-default Gfortran.
check_fortran_source_runs(${_code} SCALAPACK_Runs_OK SRC_EXT f90)
if(NOT SCALAPACK_Runs_OK)
message(STATUS "Scalapack ${SCALAPACK_LIBRARIES} not running with LAPACK ${LAPACK_LIBRARIES} and ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
endif()