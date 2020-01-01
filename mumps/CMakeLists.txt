cmake_minimum_required(VERSION 3.12)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(MumpsExamples
  LANGUAGES C Fortran)
enable_testing()

get_directory_property(hasParent PARENT_DIRECTORY)
if(NOT hasParent)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)
  find_package(MPI COMPONENTS Fortran REQUIRED)
  find_package(SCALAPACK REQUIRED)
  find_package(LAPACK REQUIRED)
  find_package(OpenMP COMPONENTS C Fortran REQUIRED)
endif()

if(NOT SCALAPACK_FOUND)
  message(STATUS "SKIP: MUMPS requires SCALAPACK")
  return()
endif()

if(NOT realbits)
  set(realbits 64)
endif()

include(mumps.cmake)

add_executable(testmumps test_mumps.f90)
if(NOT MUMPS_FOUND)
  if(NOT OpenMP_FOUND)
    message(STATUS "SKIP: MUMPS requires OpenMP")
    return()
  endif()
  include(mumps_external.cmake)
  target_link_directories(testmumps PRIVATE ${MUMPS_BINARY_DIR})
  add_dependencies(testmumps MUMPS)
endif()
target_compile_options(testmumps PRIVATE ${FFLAGS})
target_include_directories(testmumps PRIVATE ${MUMPS_INCLUDE_DIRS} ${SCALAPACK_INCLUDE_DIRS})
target_link_libraries(testmumps PRIVATE ${MUMPS_LIBRARIES} ${SCALAPACK_LIBRARIES} ${LAPACK_LIBRARIES} MPI::MPI_Fortran OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)

add_test(NAME MUMPS
  COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS}
    $<TARGET_FILE:testmumps> ${CMAKE_CURRENT_SOURCE_DIR}/input_simpletest_real)
set_tests_properties(MUMPS PROPERTIES RUN_SERIAL true TIMEOUT 15)
