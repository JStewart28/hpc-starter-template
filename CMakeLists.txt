# project settings
cmake_minimum_required(VERSION 3.18)

project(MyProject LANGUAGES C CXX VERSION 0.1.0)

# Default to C++17 so we can use if constexpr and [[maybe_unused]]
# and so GTest/GMock can build
if (NOT BLT_CXX_STD)
    set(BLT_CXX_STD "c++17" CACHE STRING "")
endif()

include(GNUInstallDirs)

# Update the path that CMAKE will search for Find_XXX.cmake files
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

##---------------------------------------------------------------------------##
## Bring up the BLT tools
## We use LLNL BLT to help with building, linking, and testing on various HPC 
## systems. Before bringing in BLT, we set a variety of flags whch tell it the 
## featurs we're interested in.
##---------------------------------------------------------------------------##
set(ENABLE_TESTS ON)
if (DEFINED BLT_SOURCE_DIR)
    # Support having a shared BLT outside of the repository if given a BLT_SOURCE_DIR
    if (NOT EXISTS ${BLT_SOURCE_DIR}/SetupBLT.cmake)
        message(FATAL_ERROR "Given BLT_SOURCE_DIR does not contain SetupBLT.cmake")
    endif()
else()
    # Use internal BLT if no BLT_SOURCE_DIR is given
    set(BLT_SOURCE_DIR "${PROJECT_SOURCE_DIR}/blt" CACHE PATH "")
    if (NOT EXISTS ${BLT_SOURCE_DIR}/SetupBLT.cmake)
        message(FATAL_ERROR
            "The BLT git submodule is not present. "
            "Either run the following two commands in your git repository: \n"
            "    git submodule init\n"
            "    git submodule update\n"
            "Or add -DBLT_SOURCE_DIR=/path/to/blt to your CMake command." )
    endif()
endif()

# Disable google test pthreads in BLT to support to ensure we compile in 
# some environments, as some compilers (e.g. craycc) and BLT aren't communicating
# on linking against pthreads.
set(gtest_disable_pthreads ON CACHE BOOL "")
include(${BLT_SOURCE_DIR}/SetupBLT.cmake)

# Tell CMAKE to find MPIAdvance
find_package(MPI_Advance REQUIRED)

# Tell CMAKE to find NuMesh
find_package(NuMesh REQUIRED)
if (NuMesh_FOUND)
  include_directories(${NuMesh_INCLUDE_DIRS})
else()
  message(FATAL_ERROR "NuMesh not found!")
endif()

# We also need MPI for this example
find_package(MPI REQUIRED)

# find dependencies
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

# Include MPI_Advance
# set( MPI_Advance_PREFIX "~/executables/mpi_advance" CACHE PATH "")
# find_package(MPI_Advance REQUIRED)

##---------------------------------------------------------------------------##
## Get the dependent packages we need: Cabana, Silo, and ClangFormat         ##
##---------------------------------------------------------------------------##
find_package(Cabana REQUIRED COMPONENTS Cabana::Cajita Cabana::cabanacore)
if( NOT Cabana_ENABLE_MPI )
  message( FATAL_ERROR "Cabana must be compiled with MPI" )
endif()
if( NOT Cabana_ENABLE_GRID )
  message( FATAL_ERROR "Cabana must be compiled with Grid support" )
endif()

# Get Clang Format to use for making sure the resulting code is
# properly formatted
find_package(CLANG_FORMAT 10)

# library
add_subdirectory(src)

# examples
add_subdirectory(examples)

# tests
add_subdirectory(tests)

# Add a target for formatting the code using Clang
if(CLANG_FORMAT_FOUND)
  file(GLOB_RECURSE FORMAT_SOURCES src/*.cpp src/*.hpp tests/*.hpp tests/*.cpp examples/*.cpp examples/*.hpp)
  add_custom_target(format
    COMMAND ${CLANG_FORMAT_EXECUTABLE} -i -style=file ${FORMAT_SOURCES}
    DEPENDS ${FORMAT_SOURCES})
endif()
