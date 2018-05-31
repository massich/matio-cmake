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

# matio_pubconf.h is deprecated but provided for backward compatibility
set(public_headers 
    ${PROJECT_SOURCE_DIR}/matio/src/matio.h
	${CMAKE_CURRENT_BINARY_DIR}/matio/src/matio_pubconf.h
	${CMAKE_CURRENT_BINARY_DIR}/matio/src/matioConfig.h
	${CMAKE_CURRENT_BINARY_DIR}/matio_export.h
	)
	
list(APPEND target_outputs "")
list(APPEND target_outputs "matio")
list(APPEND target_outputs "matio-static")

if(NOT WIN32)
	add_library(objects OBJECT ${src_SOURCES})
	set_target_properties(objects PROPERTIES POSITION_INDEPENDENT_CODE ON)
	target_include_directories(objects
							   PRIVATE ${PROJECT_SOURCE_DIR}/matio/src/
							   PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/matio/src/
	)
	add_library(matio-static STATIC $<TARGET_OBJECTS:objects>)
	set_target_properties(matio-static PROPERTIES OUTPUT_NAME matio)
	
	add_library(matio SHARED $<TARGET_OBJECTS:objects>)
else()
	add_library(matio-static STATIC ${src_SOURCES})
	add_library(matio SHARED ${src_SOURCES})
	target_sources(matio PRIVATE ${PROJECT_SOURCE_DIR}/matio/visual_studio/matio.def)
endif()

# This generates matio_export.h	
include(GenerateExportHeader)	
generate_export_header(matio)

foreach (target ${target_outputs})
	target_include_directories(${target}
		PRIVATE ${PROJECT_SOURCE_DIR}/matio/src/
		PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/matio/src/
	)
	
	if(HDF5_FOUND)
		target_link_libraries(${target} PUBLIC HDF5::HDF5)
	endif()

	if(ZLIB_FOUND)
		target_link_libraries(${target} PUBLIC ZLIB::ZLIB)
	endif()
	
	set_target_properties(${target} PROPERTIES
						  PUBLIC_HEADER "${public_headers}"
						  CXX_STANDARD_REQUIRED ON
						  CXX_VISIBILITY_PRESET hidden
						  VISIBILITY_INLINES_HIDDEN 1)
						  
	if(WIN32)
		set_target_properties(${target} PROPERTIES
							  PREFIX lib
							  IMPORT_PREFIX lib)
	else()
		target_link_libraries(${target} PUBLIC m)
	endif()
endforeach()				  

# 'make install' to the correct locations (provided by GNUInstallDirs).
install(TARGETS ${target_outputs} EXPORT libmatio
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(EXPORT libmatio NAMESPACE matio:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake)
