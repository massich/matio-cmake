add_executable(test_mat ${PROJECT_SOURCE_DIR}/matio/test/test_mat.c)

target_link_libraries( test_mat
    matio
    $(GETOPT_LIBS)
    $(HDF5_LIBS)
    $(ZLIB_LIBS)
)

add_executable(test_snprintf ${PROJECT_SOURCE_DIR}/matio/test/test_snprintf.c)
