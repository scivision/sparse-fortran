!! https://software.intel.com/en-us/mkl-developer-reference-fortran-intel-mkl-pardiso-parameters-in-tabular-form

use, intrinsic :: iso_fortran_env, only: int64, dp=>real64, stderr=>error_unit

implicit none

integer(int64) :: pt(64)
integer :: maxfct, mnum, mtype, phase, n, nrhs, error, msglvl
integer :: iparm(64)
integer :: ia(9), ja(18)
real(dp) :: dparm (64), a(18), b(8), x(8), y(8)
integer :: i, j, idum, solver
real(dp) :: waltime1, waltime2, ddum, normb, normr

external :: pardisoinit

pt = 0
iparm = 0

!! example
maxfct = 1
mnum = 1
n = 8
nrhs = 1
mtype = -2 ! real, symmetric, indefinite
solver = 10 ! use sparse direct method
msglvl = 1


!! sparse example matrix
ia = [1,5,8,10,12,15,17,18,19]

ja = [&
1, 3, 6, 7, &
2, 3, 5, &
3, 8, &
4, 7, &
5, 6, 7, &
6, 8, &
7, &
8]

a = [&
7._dp, 1._dp, 2._dp, 7._dp, &
-4._dp, 8._dp, 2._dp, &
1._dp, 5._dp, &
7._dp, 9._dp, &
5._dp, -1._dp, 5._dp, &
0._dp, 5._dp, &
11._dp, &
5._dp]

!! example rhs
do i = 1, n
  b(i) = i
end do

! -------------------------------------
!! https://software.intel.com/en-us/mkl-developer-reference-fortran-pardiso

!! initialize pardiso
call pardisoinit(pt, mtype, iparm)

!! analysis
phase = 11
call pardiso(pt, maxfct, mnum, mtype, phase, n, a, ia, ja, &
              idum, nrhs, iparm, msglvl, ddum, ddum, error, dparm)

if (error /= 0) then
  write(stderr,*) 'ERROR: pardiso reordering: code ',error
  error stop
endif

!! factorization
phase = 22
call pardiso(pt, maxfct, mnum, mtype, phase, n, a, ia, ja, &
              idum, nrhs, iparm, msglvl, ddum, ddum, error, dparm)

if (error /= 0) then
  write(stderr,*) 'ERROR: pardiso factoring: code ',error
  error stop
endif

if (iparm(33) == 1) print *,'log(determinant) = ',dparm

!! deallocate internal memory
phase = -1
call pardiso(pt, maxfct, mnum, mtype, phase, n, a, ia, ja, &
              idum, nrhs, iparm, msglvl, ddum, ddum, error, dparm)

end program