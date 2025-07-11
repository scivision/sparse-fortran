include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/mpi_launcher.cmake)

if(METIS_FOUND)
  add_executable(metis_demo metis.f90)
  target_link_libraries(metis_demo PRIVATE METIS::METIS)
  add_test(NAME Metis COMMAND metis_demo)
endif()

if(MUMPS_FOUND)
  add_executable(testmumps test_mumps.f90)
  target_link_libraries(testmumps PRIVATE MUMPS::MUMPS SCALAPACK::SCALAPACK LAPACK::LAPACK MPI::MPI_Fortran)

  add_test(NAME MUMPS COMMAND testmumps ${CMAKE_CURRENT_SOURCE_DIR}/input_simpletest_real)
  test_mpi_launcher(testmumps MUMPS ${MPIEXEC_MAX_NUMPROCS})
endif()

if("d" IN_LIST arith)
  add_executable(blacs_demo blacs_demo.f90)
  target_link_libraries(blacs_demo PRIVATE SCALAPACK::SCALAPACK LAPACK::LAPACK MPI::MPI_Fortran)
  add_test(NAME BLACS COMMAND blacs_demo)
  test_mpi_launcher(blacs_demo BLACS ${MPIEXEC_MAX_NUMPROCS})

  add_executable(scalapack_demo scalapack_demo.f90)
  target_link_libraries(scalapack_demo PRIVATE SCALAPACK::SCALAPACK LAPACK::LAPACK MPI::MPI_Fortran)
  add_test(NAME Scalapack COMMAND scalapack_demo)
  test_mpi_launcher(scalapack_demo Scalapack ${MPIEXEC_MAX_NUMPROCS})
endif()

get_property(_test_names DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY TESTS)

set_tests_properties(${_test_names} PROPERTIES
RESOURCE_LOCK cpu_mpi
TIMEOUT 15
)

if(WIN32)
  get_target_property(lib SCALAPACK::SCALAPACK INTERFACE_LINK_LIBRARIES)
  if(lib)
    list(GET lib 0 lib)
    cmake_path(GET lib PARENT_PATH libdir)
    cmake_path(SET dlldir NORMALIZE ${libdir}/../bin)
    if(IS_DIRECTORY ${dlldir})
      set_tests_properties(${_test_names} PROPERTIES
      ENVIRONMENT_MODIFICATION PATH=path_list_append:${dlldir}
      )
    endif()
  endif()
endif()


# --- pardiso

include(CheckSourceCompiles)

set(CMAKE_REQUIRED_INCLUDES ${SCALAPACK_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${SCALPACK_LIBRARIES} ${LAPACK_LIBRARIES})

check_source_compiles(Fortran
"program par
implicit none (type, external)
external :: pardisoinit, pardiso

call pardisoinit()
end program"
HAVE_PARDISO
)

if(HAVE_PARDISO)
  add_executable(pardiso_basic pardiso_basic.f90)
  target_link_libraries(pardiso_basic PRIVATE SCALAPACK::SCALAPACK LAPACK::LAPACK)
  add_test(NAME pardisoBasic COMMAND pardiso_basic)
endif()
