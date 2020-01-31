if(METIS_FOUND)
  add_executable(metis_demo metis.f90)
  target_link_libraries(metis_demo PRIVATE ${METIS_LIBRARIES})
  target_include_directories(metis_demo PRIVATE ${METIS_INCLUDE_DIRS})

  add_test(NAME Metis
    COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS} $<TARGET_FILE:metis_demo>
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

find_package(SCALAPACK)
if(SCALAPACK_FOUND)
  add_executable(blacs_demo blacs_demo.f90)
  target_link_libraries(blacs_demo PRIVATE ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES} MPI::MPI_Fortran)
  target_include_directories(blacs_demo PRIVATE ${SCALAPACK_INCLUDE_DIRS})
  add_test(NAME BLACS COMMAND blacs_demo)
  set_tests_properties(BLACS PROPERTIES TIMEOUT 15)

  add_executable(scalapack_demo scalapack_demo.f90)
  target_link_libraries(scalapack_demo PRIVATE ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES} MPI::MPI_Fortran)
  add_test(NAME Scalapack COMMAND scalapack_demo)
  set_tests_properties(Scalapack PROPERTIES TIMEOUT 15)
endif()