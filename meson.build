
# --- Scalapack
scalapack = dependency('scalapack', cmake_module_path : 'cmake/Modules', required: false, disabler: true)

# --- MUMPS
if os == 'linux'
  mumpsinc = '/usr/include'
else
  mumpsinc = ''
endif
mumpslib = fc.find_library('dmumps', required : false, disabler: true)
mumps = declare_dependency(include_directories: mumpsinc, dependencies: mumpslib)

# --- code

blacs1_exe = executable('blacs_demo', 'blacs_demo.f90',
  dependencies: [mpi, lapack, scalapack])
test('BLACS', blacs1_exe,
  suite: 'sparse',
  timeout: 10)

scalapack_exe = executable('scalapack_demo', 'scalapack_demo.f90',
  dependencies: [mpi, lapack, scalapack])
test('Scalapack', scalapack_exe,
  suite: 'sparse',
  timeout: 15)

testmumps_exe = executable('testmumps', 'test_mumps.f90',
  dependencies: [mpi, mumps, scalapack, lapack])
test('MUMPS', mpiexec,
  args: ['-np', '1', testmumps_exe, files('input_simpletest_real')],
  suite: 'sparse',
  timeout: 15)
