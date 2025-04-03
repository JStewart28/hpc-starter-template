#include <iostream>
#include <memory>
#include <type_traits>

#include <Kokkos_Core.hpp>
#include <mpi.h>

int main(int argc, char* argv[])
{
  MPI_Init( &argc, &argv );
  Kokkos::initialize( argc, argv );

  printf("Hi\n");
  
  Kokkos::finalize();
  MPI_Finalize();
	
	return 0;
}
