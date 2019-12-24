# MKL Pardiso

pardiso_basic = executable('pardiso_basic', 'pardiso_basic.f90',
  dependencies: pardiso)
test('pardisoBasic', pardiso_basic,
  suite: 'pardiso',
  timeout: 10)