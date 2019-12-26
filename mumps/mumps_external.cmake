include(ExternalProject)

ExternalProject_Add(MUMPS
  GIT_REPOSITORY https://github.com/scivision/mumps.git
  GIT_TAG master
  INSTALL_COMMAND ""  # disables the install step for the external project
)

ExternalProject_Get_Property(MUMPS BINARY_DIR SOURCE_DIR)
set(MUMPS_BINARY_DIR ${BINARY_DIR})
set(MUMPS_SOURCE_DIR ${SOURCE_DIR})

# here we have to use a priori about MUMPS, since MUMPS won't build as ExernalProject at configure time,
# which is when find_package() is run
# An alternative (messy) is a make a "superproject)" that uses both as external projects and calls CMake twice.
# This method below seems much preferable.
# Meson makes this much easier, and is a key reason to use Meson instead of CMake.
# FIXME: this doesn't cover Scotch or Metis.

set(MUMPS_LIBRARIES ${arith}mumps mumps_common pord)
set(MUMPS_INCLUDE_DIRS ${MUMPS_BINARY_DIR} ${MUMPS_SOURCE_DIR}/include)
