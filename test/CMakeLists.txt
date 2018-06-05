cmake_minimum_required(VERSION 3.2)

message("CMAKE_MODULE_PATH is " ${CMAKE_MODULE_PATH})
message("matio_DIR is " $ENV{matio_DIR})

project(matio_test)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)

find_package(matio REQUIRED)
find_package(Threads)
find_package(HDF5)
find_package(ZLIB)

if (HDF5_FOUND AND NOT TARGET HDF5::HDF5)
    add_library(HDF5::HDF5 INTERFACE IMPORTED)
    set_target_properties(HDF5::HDF5 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HDF5_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES "${HDF5_LIBRARIES}")
endif()

add_executable(hello main.cpp)
target_link_libraries(hello PUBLIC MATIO::matio)


enable_testing()
add_test(NAME check_it_runs COMMAND hello)
