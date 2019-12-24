testmumps_exe = executable('testmumps', 'test_mumps.f90',
  dependencies: [mpi, mumps, scalapack, lapack])
test('MUMPS', mpiexec,
  args: ['-np', '1', testmumps_exe, files('input_simpletest_real')],
  suite: 'mumps',
  timeout: 15)