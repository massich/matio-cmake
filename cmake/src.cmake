configure_file(
  "${PROJECT_SOURCE_DIR}/cmake/matio_pubconf.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/matio/src/matio_pubconf.h"
  ESCAPE_QUOTES @ONLY)

configure_file(
  "${PROJECT_SOURCE_DIR}/cmake/matioConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/matio/src/matioConfig.h"
  ESCAPE_QUOTES @ONLY)

set(src_SOURCES
  ${PROJECT_SOURCE_DIR}/matio/src/endian.c
  ${PROJECT_SOURCE_DIR}/matio/src/mat.c
  ${PROJECT_SOURCE_DIR}/matio/src/io.c
  ${PROJECT_SOURCE_DIR}/matio/src/inflate.c
  ${PROJECT_SOURCE_DIR}/matio/src/mat73.c
  ${PROJECT_SOURCE_DIR}/matio/src/matvar_cell.c
  ${PROJECT_SOURCE_DIR}/matio/src/matvar_struct.c
  ${PROJECT_SOURCE_DIR}/matio/src/mat4.c
  ${PROJECT_SOURCE_DIR}/matio/src/mat5.c
  ${PROJECT_SOURCE_DIR}/matio/src/snprintf.c
  ${PROJECT_SOURCE_DIR}/matio/src/read_data.c
  ${PROJECT_SOURCE_DIR}/matio/src/mat5.h
  ${PROJECT_SOURCE_DIR}/matio/src/mat73.h
  ${PROJECT_SOURCE_DIR}/matio/src/matio_private.h
  ${PROJECT_SOURCE_DIR}/matio/src/mat4.h
  ${PROJECT_SOURCE_DIR}/matio/src/matio.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio/src/matio_pubconf.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio/src/matioConfig.h
)

add_library(matio-static STATIC ${src_SOURCES} )
target_include_directories(matio-static
   PRIVATE ${PROJECT_SOURCE_DIR}/matio/src/
   PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/matio/src/
)

if(NOT WIN32)
  target_link_libraries(matio-static PUBLIC m)
  set_target_properties(matio-static PROPERTIES OUTPUT_NAME matio)
else()
  # target_link_libraries(matio PUBLIC ${GETOPT_LIB})
  set_target_properties(matio-static PROPERTIES OUTPUT_NAME libmatio-static)
  target_sources(matio-static PRIVATE ${PROJECT_SOURCE_DIR}/matio/visual_studio/matio.def)
endif()

if(HDF5_FOUND)
  target_link_libraries(matio-static
    PUBLIC HDF5::HDF5)
endif()

if(ZLIB_FOUND)
  target_link_libraries(matio-static
      PUBLIC ZLIB::ZLIB
  )
endif()

# XXX not sure it's the right thing to do...
set_target_properties(matio-static PROPERTIES
  CXX_STANDARD_REQUIRED ON
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN 1)


# This generates matio_export.h
include(GenerateExportHeader)
generate_export_header(matio-static EXPORT_FILE_NAME matio_export.h)

# matio_pubconf.h is deprecated but provided for backward compatibility
set(public_headers
  ${PROJECT_SOURCE_DIR}/matio/src/matio.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio/src/matio_pubconf.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio/src/matioConfig.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio_export.h
  )
set_target_properties(matio-static PROPERTIES PUBLIC_HEADER "${public_headers}")

# 'make install' to the correct locations (provided by GNUInstallDirs).
install(TARGETS matio-static EXPORT matio-config
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(EXPORT matio-config NAMESPACE MATIO:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake)
