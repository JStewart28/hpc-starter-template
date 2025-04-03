#!/bin/bash
# flux: --job-name=caliper_4
# flux: --nodes=1
# flux: --exclusive 
# flux: --time=10
# flux: --output={{name}}.{{jobid}}.log 

# FIXME change these to point to the right directories
SPACK_INSTALL=/usr/workspace/stewartj/spack
SPACK_ENV=${HOME}/spack_envs/hpc-starter-tioga
DIR_SCRATCH=/g/g20/stewartj/research-bridges/hpc-starter-template/build/
DIR_RUN=/p/lustre1/${USER}/hpc-starter-tioga/caliper/4

echo "Loading spack environment"
#source ${SPACK_INSTALL}/share/spack/setup-env.sh
#spack env activate ${SPACK_ENV} 

echo "Creating output directory"
mkdir -p ${DIR_RUN}
cd ${DIR_RUN}
cp -a ${DIR_SCRATCH} .
cd build
#cd /g/g20/stewartj/spack/opt/spack/linux-rhel8-zen3/cce-16.0.1/beatnik-develop-osqtaabaznsbcgdtypl6cn3sugfxe5al
#cd /g/g20/stewartj/spack_envs/beatnik_tioga/beatnik/spack-build-osqtaab/

KOKKOSTOOLARGS="--kokkos-tools-libs=${HOME}/install-tioga/caliper/lib64/libcaliper.so --kokkos-tools-args=runtime-report(profile.kokkos,aggregate_across_ranks,mpi.message.count,mpi.message.size,calc.inclusive),mpi-report"

KOKKOSARGS="--kokkos-map-device-id-by=mpi_rank ${KOKKOSTOOLARGS}"

# Make sure cray mpich supports GPU-aware communication
export MPICH_GPU_SUPPORT_ENABLED=0
export GTL_HSA_VSMSG_CUTOFF_SIZE=4096
export FI_CXI_ATS=0
export LD_LIBRARY_PATH=/opt/cray/pe/lib64/cce/:$LD_LIBRARY_PATH
echo "Starting MPI Run with ${FLUX_JOB_SIZE} processes"

# Increase allowed size of core files
ulimit -c 128
#flux run --ntasks=16 --nodes=2 --exclusive --gpus-per-task=1 --cores-per-task=8 --setopt=mpibind=verbose:1 rocketrig -x hip -n 12288 -w 16 -F 0
flux run --ntasks=4 --nodes=1 --exclusive --gpus-per-task=1 --cores-per-task=8 --setopt=mpibind=verbose:1 examples/main $KOKKOSARGS

echo "Finished MPI run with caliper data"
