configure_file(
  "${PROJECT_SOURCE_DIR}/cmake/matio_pubconf.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/matio/src/matio_pubconf.h"
  ESCAPE_QUOTES @ONLY)

configure_file(
  "${PROJECT_SOURCE_DIR}/cmake/matioConfigHeader.cmake.in"
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

set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif("${isSystemDir}" STREQUAL "-1")

add_library(matio-static STATIC ${src_SOURCES} )
target_include_directories(matio-static
   PRIVATE ${PROJECT_SOURCE_DIR}/matio/src/
   PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/matio/src/
   PUBLIC $<INSTALL_INTERFACE:include/matio>
)

add_library(matio SHARED ${src_SOURCES} )
target_include_directories(matio
    PRIVATE ${PROJECT_SOURCE_DIR}/matio/src/
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/matio/src/
    PUBLIC $<INSTALL_INTERFACE:include/matio>
)

if(NOT WIN32)
  target_link_libraries(matio PUBLIC m)
  target_link_libraries(matio-static PUBLIC m)
  set_target_properties(matio-static PROPERTIES OUTPUT_NAME matio)
else()
  # target_link_libraries(matio PUBLIC ${GETOPT_LIB})
  set_target_properties(matio PROPERTIES OUTPUT_NAME libmatio)
  set_target_properties(matio-static PROPERTIES OUTPUT_NAME libmatio-static)
  target_sources(matio PRIVATE ${PROJECT_SOURCE_DIR}/matio/visual_studio/matio.def)
endif()

if(HDF5_FOUND)
  if(WIN32)
    target_link_libraries(matio PUBLIC hdf5::hdf5-shared)
    target_link_libraries(matio-static PUBLIC hdf5::hdf5-static)
  else()
      target_link_libraries(matio PUBLIC HDF5::HDF5)
      target_link_libraries(matio-static PUBLIC HDF5::HDF5)
  endif()
endif()

if(ZLIB_FOUND)
  target_link_libraries(matio
      PUBLIC ZLIB::ZLIB
  )
  target_link_libraries(matio-static
      PUBLIC ZLIB::ZLIB
  )
endif()

# XXX not sure it's the right thing to do...
set_target_properties(matio PROPERTIES
  CXX_STANDARD_REQUIRED ON
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN 1)
set_target_properties(matio-static PROPERTIES
  CXX_STANDARD_REQUIRED ON
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN 1)


# This generates matio_export.h
include(GenerateExportHeader)
generate_export_header(matio)

# matio_pubconf.h is deprecated but provided for backward compatibility
set(public_headers
  ${PROJECT_SOURCE_DIR}/matio/src/matio.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio/src/matio_pubconf.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio/src/matioConfig.h
  ${CMAKE_CURRENT_BINARY_DIR}/matio_export.h
  )
set_target_properties(matio PROPERTIES PUBLIC_HEADER "${public_headers}")

include(CMakePackageConfigHelpers)
set(MATIO_CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}" CACHE
    STRING "install path for xmatioConfig.cmake")

configure_package_config_file(${PROJECT_SOURCE_DIR}/cmake/matioConfig.cmake.in
                              "${CMAKE_CURRENT_BINARY_DIR}/matioConfig.cmake"
                              INSTALL_DESTINATION ${MATIO_CMAKECONFIG_INSTALL_DIR})

# 'make install' to the correct locations (provided by GNUInstallDirs).
install(TARGETS matio matio-static EXPORT matio-targets
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/matio
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/matioConfig.cmake
        DESTINATION ${MATIO_CMAKECONFIG_INSTALL_DIR})
install(EXPORT matio-targets
        FILE matioTargets.cmake
        NAMESPACE MATIO::
        DESTINATION ${MATIO_CMAKECONFIG_INSTALL_DIR})
