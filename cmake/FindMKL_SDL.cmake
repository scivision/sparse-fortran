# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindMKL_SDL
-------
Cauã Chagas.

Finds the Single Dynamic Library (SDL) of MKL. 

Imported Targets
^^^^^^^^^^^^^^^^

MKL_SDL::MKL_SDL

Result Variables
^^^^^^^^^^^^^^^^

``MKL_SDL_FOUND``
  MKL_SDL libraries were found
``MKL_SDL_LIBRARIES``
  MKL_SDL library files
``MKL_SDL_INCLUDE_DIRS``
  MKL_SDL include directories


#]=======================================================================]


find_library(MKL_LIBRARY
  NAMES "libmkl_rt.so"
  HINTS ${MKLROOT}
  PATH_SUFFIXES lib lib/intel64
  NO_DEFAULT_PATH
)

find_path(MKL_INCLUDE_DIR
  NAMES mkl_pardiso.h
  HINTS ${MKLROOT}
  PATH_SUFFIXES include
  NO_DEFAULT_PATH
)


include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(MKL_SDL HANDLE_COMPONENTS
    REQUIRED_VARS MKL_LIBRARY MKL_INCLUDE_DIR
)

if(MKL_SDL_FOUND)

  set(HAVE_PARDISO true)
  set(MKL_SDL_LIBRARIES ${MKL_LIBRARY})
  set(MKL_SDL_INCLUDE_DIRS ${MKL_INCLUDE_DIR})

  if(NOT TARGET MKL_SDL::MKL_SDL)
    add_library(MKL_SDL::MKL_SDL INTERFACE IMPORTED)
    set_property(TARGET MKL_SDL::MKL_SDL PROPERTY INTERFACE_LINK_LIBRARIES "${MKL_SDL_LIBRARIES}")
    set_property(TARGET MKL_SDL::MKL_SDL PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${MKL_SDL_INCLUDE_DIR}")
  endif()
endif(MKL_SDL_FOUND)

mark_as_advanced(MKL_INCLUDE_DIR MKL_LIBRARY)
