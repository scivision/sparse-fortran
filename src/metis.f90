!! https://people.math.sc.edu/Burkardt/f_src/metis_test/metis_test.f90
! GNU LGPL license.  Author: John Burkardt

program test_metis

implicit none (type, external)

integer, parameter  :: nvtxs=6, nedges=7, ncon=1, nparts =2
integer :: xadj(nvtxs+1), adjncy(2*nedges), part(nvtxs), j, objval, refpart(nvtxs), adjwgt(2*nedges)
integer :: options(40)
integer, dimension(nvtxs) :: vwgt, vsize
real :: tpwgts(nparts*ncon), ubvec(ncon)

external :: METIS_SetDefaultOptions, METIS_PartGraphKway

call METIS_SetDefaultOptions(options)

options = 0
options(7) = 10
options(8) = 1
options(16) = 1
options(17) = 30

ubvec = 1.001
tpwgts = 0.5

vwgt = 1
vsize = 1
adjwgt = 1

xadj=[0, 2, 5, 7, 9, 12, 14]
adjncy=[1,3,0,4,2,1,5,0,4,3,1,5,4,2]

call METIS_PartGraphKway(nvtxs, ncon, xadj, adjncy, vwgt, vsize, adjwgt, nparts, tpwgts, ubvec, options, objval, part)

print '(15I3)', part

refpart = [1,1,0,1,0,0]

if(any(part /= refpart)) error stop 'metis failed to order'

end program
