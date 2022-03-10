# Sparse Fortran libraries

![Actions Status](https://github.com/scivision/sparse-fortran/workflows/ci/badge.svg)

Examples using BLACS, SCALAPACK, MUMPS, PARDISO for solving sparse arrays in Fortran.

For Linux, MUMPS can be easily obtained:

* Ubuntu / Debian: `apt install libmumps-dev`
* CentOS: `apt install mumps-devel`

```sh
cmake -B build
cmake --build build
```

The simple examples included test the parallel functionality of MUMPS.
