# Finds Scalapack, tests, and if not found or broken, autobuild scalapack
include(ExternalProject)

if(NOT scalapack_external)
  if(autobuild)
    find_package(SCALAPACK)
  else()
    find_package(SCALAPACK REQUIRED)
  endif()
endif()

if(SCALAPACK_FOUND OR TARGET SCALAPACK::SCALAPACK)
  return()
endif()

set(scalapack_external true CACHE BOOL "build ScaLapack")

if(NOT SCALAPACK_ROOT)
  set(SCALAPACK_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(SCALAPACK_LIBRARIES
${SCALAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}scalapack${CMAKE_STATIC_LIBRARY_SUFFIX}
${SCALAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}blacs${CMAKE_STATIC_LIBRARY_SUFFIX})

set(scalapack_cmake_args
-DCMAKE_INSTALL_PREFIX:PATH=${SCALAPACK_ROOT}
-DLAPACK_ROOT:PATH=${LAPACK_ROOT}
-DBUILD_SHARED_LIBS:BOOL=false
-DCMAKE_BUILD_TYPE=Release
-DBUILD_TESTING:BOOL=false
-Dautobuild:BOOL=false
)

ExternalProject_Add(SCALAPACK
GIT_REPOSITORY ${scalapack_git}
GIT_TAG ${scalapack_tag}
CMAKE_ARGS ${scalapack_cmake_args}
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD ON
DEPENDS LAPACK::LAPACK
)

add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED)
target_link_libraries(SCALAPACK::SCALAPACK INTERFACE "${SCALAPACK_LIBRARIES}")

# race condition for linking without this
add_dependencies(SCALAPACK::SCALAPACK SCALAPACK)
