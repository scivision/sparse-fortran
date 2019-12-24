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