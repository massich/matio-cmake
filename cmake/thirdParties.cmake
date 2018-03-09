
find_package(Threads)

find_package(HDF5)
if(HDF5_FOUND)
    set(HAVE_HDF5 1)
endif()

find_package(ZLIB)
if(ZLIB_FOUND)
    set(HAVE_ZLIB 1)
endif()
