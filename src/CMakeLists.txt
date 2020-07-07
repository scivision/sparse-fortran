if(METIS_FOUND)
  add_executable(metis_demo metis.f90)
  target_link_libraries(metis_demo PRIVATE METIS::METIS)

  add_test(NAME Metis
    COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS} $<TARGET_FILE:metis_demo>
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

find_package(LAPACK)
find_package(SCALAPACK)
if(LAPACK_FOUND AND SCALAPACK_FOUND AND "d" IN_LIST arith)
  add_executable(blacs_demo blacs_demo.f90)
  target_link_libraries(blacs_demo PRIVATE SCALAPACK::SCALAPACK LAPACK::LAPACK MPI::MPI_Fortran)
  add_test(NAME BLACS COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS} $<TARGET_FILE:blacs_demo>)
  set_tests_properties(BLACS PROPERTIES TIMEOUT 15)

  add_executable(scalapack_demo scalapack_demo.f90)
  target_link_libraries(scalapack_demo PRIVATE SCALAPACK::SCALAPACK LAPACK::LAPACK MPI::MPI_Fortran)
  add_test(NAME Scalapack COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS} $<TARGET_FILE:scalapack_demo>)
  set_tests_properties(Scalapack PROPERTIES TIMEOUT 15)
endif()
