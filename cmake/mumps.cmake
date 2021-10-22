# Intel MKL-compiled MUMPS requires at the linker for the main executable:
# mkl_scalapack_lp64 mkl_blacs_intelmpi_lp64 mkl_intel_lp64 mkl_intel_thread mkl_core
#
# easily obtain MUMPS without compiling:
# CentOS 6/7 EPEL: yum install mumps-devel
# Ubuntu / Debian: apt install libmumps-dev

include(ExternalProject)

# --- prereqs
include(${CMAKE_CURRENT_LIST_DIR}/lapack.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/scalapack.cmake)

# --- MUMPS

if(NOT mumps_external AND (MUMPS_ROOT OR (DEFINED ENV{MUMPS_ROOT}) OR (CMAKE_Fortran_COMPILER_ID STREQUAL GNU)))
  set(mumps_comp ${arith})

  if(autobuild)
    find_package(MUMPS COMPONENTS ${mumps_comp})
  else()
    find_package(MUMPS COMPONENTS ${mumps_comp} REQUIRED)
  endif()

  if(MUMPS_HAVE_Scotch)
    find_package(Scotch COMPONENTS parallel ESMUMPS REQUIRED)
    find_package(METIS COMPONENTS parallel REQUIRED)
  endif()

  if(MUMPS_HAVE_OPENMP)
    find_package(OpenMP COMPONENTS C Fortran REQUIRED)
    target_link_libraries(MUMPS::MUMPS INTERFACE OpenMP::OpenMP_Fortran OpenMP::OpenMP_C)
  endif()
endif()

if(MUMPS_FOUND OR TARGET MUMPS::MUMPS)
  return()
endif()

set(mumps_external true CACHE BOOL "build Mumps")

if(NOT MUMPS_ROOT)
  set(MUMPS_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(MUMPS_INCLUDE_DIRS ${MUMPS_ROOT}/include)
set(MUMPS_LIBRARIES)

foreach(a ${arith})
  list(APPEND MUMPS_LIBRARIES ${MUMPS_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}${a}mumps${CMAKE_STATIC_LIBRARY_SUFFIX})
endforeach()

list(APPEND MUMPS_LIBRARIES
${MUMPS_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mumps_common${CMAKE_STATIC_LIBRARY_SUFFIX}
${MUMPS_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}pord${CMAKE_STATIC_LIBRARY_SUFFIX})

set(mumps_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${MUMPS_ROOT}
-DSCALAPACK_ROOT:PATH=${SCALAPACK_ROOT}
-DLAPACK_ROOT:PATH=${LAPACK_ROOT}
-DBUILD_SHARED_LIBS:BOOL=false
-DCMAKE_BUILD_TYPE=Release
-DBUILD_TESTING:BOOL=false
-Dscotch:BOOL=${scotch}
-Dopenmp:BOOL=false
-Dparallel:BOOL=true
-Dautobuild:BOOL=false
)

ExternalProject_Add(MUMPS
GIT_REPOSITORY ${mumps_git}
GIT_TAG ${mumps_tag}
CMAKE_ARGS ${mumps_cmake_args}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
BUILD_BYPRODUCTS ${MUMPS_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD ON
DEPENDS SCALAPACK::SCALAPACK
)

file(MAKE_DIRECTORY ${MUMPS_INCLUDE_DIRS})

add_library(MUMPS::MUMPS INTERFACE IMPORTED)
target_link_libraries(MUMPS::MUMPS INTERFACE "${MUMPS_LIBRARIES}")
target_include_directories(MUMPS::MUMPS INTERFACE ${MUMPS_INCLUDE_DIRS})

# race condition for linking without this
add_dependencies(MUMPS::MUMPS MUMPS)
