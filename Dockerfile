FROM continuumio/miniconda3:latest
RUN /opt/conda/bin/conda install compilers mpich-mpifort mkl mkl-include mumps-mpi blas=*=mkl cmake make -c defaults -c conda-forge -y
RUN /opt/conda/bin/conda clean --all --force-pkgs-dirs --yes
RUN /opt/conda/bin/git clone --depth=1 https://github.com/scivision/sparse-fortran
