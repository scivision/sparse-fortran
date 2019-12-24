fc = meson.get_compiler('fortran')

mklroot = get_option('mklroot')

mpiexec = find_program('mpiexec')
mpi = dependency('mpi', language: 'fortran')

# --- Lapack
if mklroot == ''
  lapack = dependency('lapack')
else # MKL
  lapack = []
  n1 = fc.get_id() == 'gcc' ? 'mkl_gf_lp64' : 'mkl_intel_lp64'
  names = [n1, 'mkl_intel_thread', 'mkl_core']
  foreach n : names
    lapack += fc.find_library(n, dirs: mkllib_root)
  endforeach
  lapack += intelMP_lib
endif

if not fc.links('print *,disnan(0.); end', dependencies: lapack, name: 'LAPACK')
  lapack = disabler()
endif

# --- Scalapack
scalapack = dependency('scalapack', cmake_module_path : 'cmake/Modules', required: false, disabler: true)

# --- MUMPS
mumpsroot = get_option('mumpsroot')
if mumpsroot == ''
  mumpsinc = '/usr/include'
  mumpslib = fc.find_library('dmumps', required : false, disabler: true)
else
  mumpsinc = mumpsroot / 'include'
  mumpslib = fc.find_library('dmumps', dirs: mumpsroot, required : false, disabler: true)
endif

mumps = declare_dependency(include_directories: mumpsinc, dependencies: mumpslib)
