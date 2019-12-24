# Sparse Fortran libraries

[![Actions Status](https://github.com/scivision/sparse-fortran/workflows/ci_cmake/badge.svg)](https://github.com/scivision/sparse-fortran/actions)
[![Actions Status](https://github.com/scivision/sparse-fortran/workflows/ci_meson/badge.svg)](https://github.com/scivision/sparse-fortran/actions)


Examples using BLACS, SCALAPACK, MUMPS, PARDISO for solving sparse arrays in Fortran.

## MUMPS

Using MUMPS can be challenging to start in any language due to the number of prereqs that may have to be compiled.
For Linux, MUMPS can be easily obtained:

* Ubuntu/Debian: `apt install libmumps-dev`
* CentOS: `apt install mumps-devel`

The simple examples included tests the parallel functionality of MUMPS.
