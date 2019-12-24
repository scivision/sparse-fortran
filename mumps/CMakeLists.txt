include(mumps.cmake)

if(MUMPS_FOUND)
  add_executable(testmumps test_mumps.f90)
  target_compile_options(testmumps PRIVATE ${FFLAGS})
  target_include_directories(testmumps PRIVATE ${MUMPS_INCLUDE_DIRS})
  target_link_libraries(testmumps PRIVATE ${MUMPS_LIBRARIES} MPI::MPI_Fortran)

  add_test(NAME MUMPS
    COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS} $<TARGET_FILE:testmumps>
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  set_tests_properties(MUMPS PROPERTIES RUN_SERIAL true TIMEOUT 15)
endif()
