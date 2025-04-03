GTL_DIR=/opt/cray/pe/mpich/8.1.30/gtl/lib/  # Replace with actual path
cmake -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath=${GTL_DIR} -L${GTL_DIR} -lmpi_gtl_hsa" ..
