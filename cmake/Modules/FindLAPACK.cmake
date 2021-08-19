# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:

FindLapack
----------

* Michael Hirsch, Ph.D. www.scivision.dev
* David Eklund

Let Michael know if there are more MKL / Lapack / compiler combination you want.
Refer to https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor

Finds LAPACK libraries for C / C++ / Fortran.
Works with Netlib Lapack / LapackE, Atlas and Intel MKL.
Intel MKL relies on having environment variable MKLROOT set, typically by sourcing
mklvars.sh beforehand.

Why not the FindLapack.cmake built into CMake? It has a lot of old code for
infrequently used Lapack libraries and is unreliable for me.

Tested on Linux, MacOS and Windows with:
* GCC / Gfortran
* Clang / Flang
* PGI (pgcc, pgfortran)
* Intel (icc, ifort)


Parameters
^^^^^^^^^^

COMPONENTS default to Netlib LAPACK / LapackE, otherwise:

``MKL``
  Intel MKL for MSVC, ICL, ICC, GCC and PGCC -- sequential by default, or add TBB or MPI as well
``OpenMP``
  Intel MPI with OpenMP threading addition to MKL
``TBB``
  Intel MPI + TBB for MKL
``MKL64``
  MKL only: 64-bit integers  (default is 32-bit integers)

``LAPACKE``
  Netlib LapackE for C / C++
``Netlib``
  Netlib Lapack for Fortran
``OpenBLAS``
  OpenBLAS Lapack for Fortran

``LAPACK95``
  get Lapack95 interfaces for MKL or Netlib (must also specify one of MKL, Netlib)


Result Variables
^^^^^^^^^^^^^^^^

``LAPACK_FOUND``
  Lapack libraries were found
``LAPACK_<component>_FOUND``
  LAPACK <component> specified was found
``LAPACK_LIBRARIES``
  Lapack library files (including BLAS
``LAPACK_INCLUDE_DIRS``
  Lapack include directories (for C/C++)


References
^^^^^^^^^^

* Pkg-Config and MKL:  https://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-and-pkg-config-tool
* MKL for Windows: https://software.intel.com/en-us/mkl-windows-developer-guide-static-libraries-in-the-lib-intel64-win-directory
* MKL Windows directories: https://software.intel.com/en-us/mkl-windows-developer-guide-high-level-directory-structure
* Atlas http://math-atlas.sourceforge.net/errata.html#LINK
* MKL LAPACKE (C, C++): https://software.intel.com/en-us/mkl-linux-developer-guide-calling-lapack-blas-and-cblas-routines-from-c-c-language-environments
#]=======================================================================]

include(CheckSourceCompiles)

# clear to avoid endless appending on subsequent calls
set(LAPACK_LIBRARY)
set(LAPACK_INCLUDE_DIR)

# ===== functions ==========

function(atlas_libs)

find_library(ATLAS_LIB
  NAMES atlas
  PATH_SUFFIXES atlas)

pkg_check_modules(pc_atlas_lapack lapack-atlas)

find_library(LAPACK_ATLAS
  NAMES ptlapack lapack_atlas lapack
  NAMES_PER_DIR
  PATH_SUFFIXES atlas
  HINTS ${pc_atlas_lapack_LIBRARY_DIRS} ${pc_atlas_lapack_LIBDIR})

pkg_check_modules(pc_atlas_blas blas-atlas)

find_library(BLAS_LIBRARY
  NAMES ptf77blas f77blas blas
  NAMES_PER_DIR
  PATH_SUFFIXES atlas
  HINTS ${pc_atlas_blas_LIBRARY_DIRS} ${pc_atlas_blas_LIBDIR})
# === C ===
find_library(BLAS_C_ATLAS
  NAMES ptcblas cblas
  NAMES_PER_DIR
  PATH_SUFFIXES atlas
  HINTS ${pc_atlas_blas_LIBRARY_DIRS} ${pc_atlas_blas_LIBDIR})

find_path(LAPACK_INCLUDE_DIR
  NAMES cblas-atlas.h cblas.h clapack.h
  HINTS ${pc_atlas_blas_INCLUDE_DIRS} ${pc_atlas_blas_LIBDIR})

#===========
if(LAPACK_ATLAS AND BLAS_C_ATLAS AND BLAS_LIBRARY AND ATLAS_LIB)
  set(LAPACK_Atlas_FOUND true PARENT_SCOPE)
  set(LAPACK_LIBRARY ${LAPACK_ATLAS} ${BLAS_C_ATLAS} ${BLAS_LIBRARY} ${ATLAS_LIB})
  list(APPEND LAPACK_LIBRARY ${CMAKE_THREAD_LIBS_INIT})
endif()

set(LAPACK_LIBRARY ${LAPACK_LIBRARY} PARENT_SCOPE)
set(LAPACK_INCLUDE_DIR ${LAPACK_INCLUDE_DIR} PARENT_SCOPE)

endfunction(atlas_libs)

#=======================

function(netlib_libs)

if(LAPACK95 IN_LIST LAPACK_FIND_COMPONENTS)
  find_path(LAPACK95_INCLUDE_DIR
    NAMES f95_lapack.mod
    HINTS ${LAPACK95_ROOT}
    PATH_SUFFIXES include)

  find_library(LAPACK95_LIBRARY
    NAMES lapack95
    HINTS ${LAPACK95_ROOT})

  if(NOT (LAPACK95_LIBRARY AND LAPACK95_INCLUDE_DIR))
    return()
  endif()

  set(LAPACK95_INCLUDE_DIR ${LAPACK95_INCLUDE_DIR} PARENT_SCOPE)
  set(LAPACK95_LIBRARY ${LAPACK95_LIBRARY} PARENT_SCOPE)
  set(LAPACK_LAPACK95_FOUND true PARENT_SCOPE)
endif(LAPACK95 IN_LIST LAPACK_FIND_COMPONENTS)


pkg_search_module(pc_lapack lapack-netlib lapack)

find_library(LAPACK_LIBRARY
  NAMES lapack
  HINTS ${pc_lapack_LIBRARY_DIRS} ${pc_lapack_LIBDIR}
  PATH_SUFFIXES lapack lapack/lib)
if(NOT LAPACK_LIBRARY)
  return()
endif()

if(LAPACKE IN_LIST LAPACK_FIND_COMPONENTS)
  pkg_check_modules(pc_lapacke lapacke)
  find_library(LAPACKE_LIBRARY
    NAMES lapacke
    HINTS ${pc_lapacke_LIBRARY_DIRS} ${pc_lapacke_LIBDIR}
    PATH_SUFFIXES lapack lapack/lib)

  # lapack/include for Homebrew
  find_path(LAPACKE_INCLUDE_DIR
    NAMES lapacke.h
    HINTS ${pc_lapacke_INCLUDE_DIRS} ${pc_lapacke_LIBDIR}
    PATH_SUFFIXES lapack lapack/include)
  if(NOT (LAPACKE_LIBRARY AND LAPACKE_INCLUDE_DIR))
    return()
  endif()

  set(LAPACK_LAPACKE_FOUND true PARENT_SCOPE)
  list(APPEND LAPACK_INCLUDE_DIR ${LAPACKE_INCLUDE_DIR})
  list(APPEND LAPACK_LIBRARY ${LAPACKE_LIBRARY})
  mark_as_advanced(LAPACKE_LIBRARY LAPACKE_INCLUDE_DIR)
endif(LAPACKE IN_LIST LAPACK_FIND_COMPONENTS)

pkg_search_module(pc_blas blas-netlib blas)
# Netlib on Cygwin and others

find_library(BLAS_LIBRARY
  NAMES refblas blas
  NAMES_PER_DIR
  HINTS ${pc_blas_LIBRARY_DIRS} ${pc_blas_LIBDIR}
  PATH_SUFFIXES lapack lapack/lib blas)

if(NOT BLAS_LIBRARY)
  return()
endif()

list(APPEND LAPACK_LIBRARY ${BLAS_LIBRARY})
set(LAPACK_Netlib_FOUND true PARENT_SCOPE)

list(APPEND LAPACK_LIBRARY ${CMAKE_THREAD_LIBS_INIT})

set(LAPACK_LIBRARY ${LAPACK_LIBRARY} PARENT_SCOPE)
set(LAPACK_INCLUDE_DIR ${LAPACK_INCLUDE_DIR} PARENT_SCOPE)

endfunction(netlib_libs)

#===============================
function(openblas_libs)

pkg_check_modules(pc_lapack lapack-openblas)
find_library(LAPACK_LIBRARY
  NAMES lapack
  HINTS ${pc_lapack_LIBRARY_DIRS} ${pc_lapack_LIBDIR}
  PATH_SUFFIXES openblas)

pkg_check_modules(pc_blas blas-openblas)
find_library(BLAS_LIBRARY
  NAMES openblas blas
  NAMES_PER_DIR
  HINTS ${pc_blas_LIBRARY_DIRS} ${pc_blas_LIBDIR}
  PATH_SUFFIXES openblas)

find_path(LAPACK_INCLUDE_DIR
  NAMES cblas-openblas.h cblas.h f77blas.h openblas_config.h
  HINTS ${pc_lapack_INCLUDE_DIRS})

if(NOT (LAPACK_LIBRARY AND BLAS_LIBRARY))
  return()
endif()

list(APPEND LAPACK_LIBRARY ${BLAS_LIBRARY})
set(LAPACK_OpenBLAS_FOUND true PARENT_SCOPE)

list(APPEND LAPACK_LIBRARY ${CMAKE_THREAD_LIBS_INIT})

set(LAPACK_LIBRARY ${LAPACK_LIBRARY} PARENT_SCOPE)
set(LAPACK_INCLUDE_DIR ${LAPACK_INCLUDE_DIR} PARENT_SCOPE)

endfunction(openblas_libs)

#===============================

function(find_mkl_libs)
# https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor

set(_mkl_libs ${ARGV})
if((UNIX AND NOT APPLE) AND CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  list(INSERT _mkl_libs 0 mkl_gf_${_mkl_bitflag}lp64)
else()
  list(INSERT _mkl_libs 0 mkl_intel_${_mkl_bitflag}lp64)
endif()

# Note: Don't remove items from PATH_SUFFIXES unless you're extensively testing,
# each path is there for a specific reason!

foreach(s ${_mkl_libs})
  find_library(LAPACK_${s}_LIBRARY
    NAMES ${s}
    PATHS ${MKLROOT}
    PATH_SUFFIXES lib/intel64
    HINTS ${pc_mkl_LIBRARY_DIRS} ${pc_mkl_LIBDIR}
    NO_DEFAULT_PATH
  )

  if(NOT LAPACK_${s}_LIBRARY)
    return()
  endif()

  list(APPEND LAPACK_LIBRARY ${LAPACK_${s}_LIBRARY})
endforeach()

find_path(LAPACK_INCLUDE_DIR
  NAMES mkl_lapack.h
  HINTS ${MKLROOT}
  PATH_SUFFIXES include
  NO_DEFAULT_PATH
)

if(NOT LAPACK_INCLUDE_DIR)
  return()
endif()

set(LAPACK_LIBRARY ${LAPACK_LIBRARY} PARENT_SCOPE)
set(LAPACK_INCLUDE_DIR ${LAPACK_INCLUDE_DIR} PARENT_SCOPE)

endfunction(find_mkl_libs)

# ========== main program

if(NOT (OpenBLAS IN_LIST LAPACK_FIND_COMPONENTS
  OR Netlib IN_LIST LAPACK_FIND_COMPONENTS
  OR Atlas IN_LIST LAPACK_FIND_COMPONENTS
  OR MKL IN_LIST LAPACK_FIND_COMPONENTS))
  if(DEFINED ENV{MKLROOT})
    list(APPEND LAPACK_FIND_COMPONENTS MKL)
  else()
    list(APPEND LAPACK_FIND_COMPONENTS Netlib)
  endif()
endif()

find_package(PkgConfig)
find_package(Threads)

# ==== generic MKL variables ====

if(MKL IN_LIST LAPACK_FIND_COMPONENTS)
  # we have to sanitize MKLROOT if it has Windows backslashes (\) otherwise it will break at build time
  # double-quotes are necessary per CMake to_cmake_path docs.
  file(TO_CMAKE_PATH "$ENV{MKLROOT}" MKLROOT)

  list(APPEND CMAKE_PREFIX_PATH ${MKLROOT}/tools/pkgconfig)

  if(BUILD_SHARED_LIBS)
    set(_mkltype dynamic)
  else()
    set(_mkltype static)
  endif()

  if(MKL64 IN_LIST LAPACK_FIND_COMPONENTS)
    set(_mkl_bitflag i)
  else()
    set(_mkl_bitflag)
  endif()

  set(_mkl_libs)
  if(LAPACK95 IN_LIST LAPACK_FIND_COMPONENTS)
    find_mkl_libs(mkl_blas95_${_mkl_bitflag}lp64 mkl_lapack95_${_mkl_bitflag}lp64)
    if(LAPACK_LIBRARY)
      set(LAPACK95_LIBRARY ${LAPACK_LIBRARY})
      set(LAPACK_LIBRARY)
      set(LAPACK95_INCLUDE_DIR ${LAPACK_INCLUDE_DIR})
      set(LAPACK_LAPACK95_FOUND true)
    endif()
  endif()

  set(_tbb)
  if(TBB IN_LIST LAPACK_FIND_COMPONENTS)
    list(APPEND _mkl_libs mkl_tbb_thread mkl_core)
    set(_tbb tbb stdc++)
  elseif(OpenMP IN_LIST LAPACK_FIND_COMPONENTS)
    pkg_check_modules(pc_mkl mkl-${_mkltype}-${_mkl_bitflag}lp64-iomp)

    set(_mp iomp5)
    if(WIN32)
      set(_mp libiomp5md)
    endif()
    list(APPEND _mkl_libs mkl_intel_thread mkl_core ${_mp})
  else()
    pkg_check_modules(pc_mkl mkl-${_mkltype}-${_mkl_bitflag}lp64-seq)
    list(APPEND _mkl_libs mkl_sequential mkl_core)
  endif()

  find_mkl_libs(${_mkl_libs})

  if(LAPACK_LIBRARY)

    if(NOT WIN32)
      list(APPEND LAPACK_LIBRARY ${_tbb} ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS} m)
    endif()

    set(LAPACK_MKL_FOUND true)

    if(MKL64 IN_LIST LAPACK_FIND_COMPONENTS)
      set(LAPACK_MKL64_FOUND true)
    endif()

    if(OpenMP IN_LIST LAPACK_FIND_COMPONENTS)
      set(LAPACK_OpenMP_FOUND true)
    endif()

    if(TBB IN_LIST LAPACK_FIND_COMPONENTS)
      set(LAPACK_TBB_FOUND true)
    endif()
  endif()

elseif(Atlas IN_LIST LAPACK_FIND_COMPONENTS)

  atlas_libs()

elseif(Netlib IN_LIST LAPACK_FIND_COMPONENTS)

  netlib_libs()

elseif(OpenBLAS IN_LIST LAPACK_FIND_COMPONENTS)

  openblas_libs()

endif()

# -- verify library works

function(lapack_check)

get_property(enabled_langs GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NOT Fortran IN_LIST enabled_langs)
  set(LAPACK_links true PARENT_SCOPE)
  return()
endif()

set(CMAKE_REQUIRED_FLAGS)
set(CMAKE_REQUIRED_LINK_OPTIONS)
set(CMAKE_REQUIRED_INCLUDES)
set(CMAKE_REQUIRED_LIBRARIES ${LAPACK_LIBRARY})

foreach(i s d)
  check_source_compiles(Fortran
  "program check_lapack
  implicit none (type, external)
  external :: ${i}isnan
  end program" LAPACK_${i}_links)

  if(LAPACK_${i}_links)
    set(LAPACK_${i}_FOUND true PARENT_SCOPE)
    set(LAPACK_links true)
  endif()

endforeach()

set(LAPACK_links ${LAPACK_links} PARENT_SCOPE)

endfunction(lapack_check)

# --- Check that Scalapack links

if(LAPACK_LIBRARY)
  lapack_check()
endif()


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LAPACK
  REQUIRED_VARS LAPACK_LIBRARY LAPACK_links
  HANDLE_COMPONENTS)

set(BLAS_LIBRARIES ${BLAS_LIBRARY})
set(LAPACK_LIBRARIES ${LAPACK_LIBRARY})
set(LAPACK_INCLUDE_DIRS ${LAPACK_INCLUDE_DIR})

if(LAPACK_FOUND)
# need if _FOUND guard to allow project to autobuild; can't overwrite imported target even if bad
  if(NOT TARGET BLAS::BLAS)
    add_library(BLAS::BLAS INTERFACE IMPORTED)
    set_target_properties(BLAS::BLAS PROPERTIES
                          INTERFACE_LINK_LIBRARIES "${BLAS_LIBRARY}"
                        )
  endif()

  if(NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK INTERFACE IMPORTED)
    set_target_properties(LAPACK::LAPACK PROPERTIES
                          INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARY}"
                          INTERFACE_INCLUDE_DIRECTORIES "${LAPACK_INCLUDE_DIR}"
                        )
  endif()

  if(LAPACK_LAPACK95_FOUND)
    set(LAPACK95_LIBRARIES ${LAPACK95_LIBRARY})
    set(LAPACK95_INCLUDE_DIRS ${LAPACK95_INCLUDE_DIR})

    if(NOT TARGET LAPACK::LAPACK95)
      add_library(LAPACK::LAPACK95 INTERFACE IMPORTED)
      set_target_properties(LAPACK::LAPACK95 PROPERTIES
        INTERFACE_LINK_LIBRARIES "${LAPACK95_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${LAPACK95_INCLUDE_DIR}"
      )
    endif()
  endif()
endif()

mark_as_advanced(LAPACK_LIBRARY LAPACK_INCLUDE_DIR)
