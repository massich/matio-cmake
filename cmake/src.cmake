set(MATIO_PLATFORM ${CMAKE_SYSTEM_PROCESSOR}-unknown-${CMAKE_SYSTEM_NAME})

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
add_library(matio STATIC ${src_SOURCES} )
target_include_directories(matio
    PRIVATE ${PROJECT_SOURCE_DIR}/matio/src/
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/matio/src/
)

if(NOT WIN32)
  target_link_libraries(matio PUBLIC m)
endif()

if(HAVE_HDF5)
  target_link_libraries(matio
      PUBLIC ${HDF5_LIBRARIES}
  )
endif()

if(HAVE_ZLIB)
  target_link_libraries(matio
      PUBLIC ZLIB::ZLIB
  )
endif()

# XXX not sure it's the right thing to do...
set_target_properties(matio PROPERTIES
  CXX_STANDARD_REQUIRED ON
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN 1)

# This generates matio_export.h
include(GenerateExportHeader)
generate_export_header(matio)
