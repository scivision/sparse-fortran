# Sparse Fortran libraries

![Actions Status](https://github.com/scivision/sparse-fortran/workflows/ci_cmake/badge.svg)
![Actions Status](https://github.com/scivision/sparse-fortran/workflows/ci_meson/badge.svg)

Examples using BLACS, SCALAPACK, MUMPS, PARDISO for solving sparse arrays in Fortran.

## MUMPS

Using MUMPS can be challenging to start in any language due to the number of prereqs that may have to be compiled.
For Linux, MUMPS can be easily obtained:

* Ubuntu / Debian: `apt install libmumps-dev`
* CentOS: `apt install mumps-devel`

With Anaconda/Miniconda (only tested with Linux):

* Mpich: `conda install compilers mpich-mpifort mkl mkl-include mumps-mpi blas=*=mkl cmake make -c conda-forge`
* Openmpi: `conda install compilers openmpi-mpifort mkl mkl-include mumps-mpi blas=*=mkl cmake make -c conda-forge`

## With Docker

In a directory with the [Dockerfile](./Dockerfile)

```sh
docker build -t sp-fortran .
docker run -it sp-fortran
cd sparse-fortran
```

### Build with CMake

Since Conda does not appear to define MKLROOT, the user using MKL from Conda must either define environment variable MKLROOT=$CONDA_PREFIX or specify at the cmake configure link:

* Linux, MacOS: `-DMKLROOT=$CONDA_PREFIX`
* Windows Powershell: `-DMKLROOT=$env:conda_prefix
* Windows Command Prompt: `-MKLROOT=%conda_prefix`

```sh
cmake -B build  # add here -DMKLROOT=... if needed
cmake --build build
```

The simple examples included test the parallel functionality of MUMPS.
