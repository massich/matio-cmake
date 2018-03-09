# Options

# Option to Enable coverage testing
option( COVERAGE "Enable coverage testing" OFF )

# Option to on debugging
option( DEBUG "on debugging" ON )

# Option to extended sparse matrix data types not supported in Matlab
option( EXTENDED_SPARSE "extended sparse matrix data types not supported in Matlab" ON )

# Option to Enable LINUX
option( LINUX "Enable LINUX" OFF )

# Option to MAT v7.3 file support
option( MAT73 "MAT v7.3 file support" ON )

# Option to on profile
option( PROFILE "on profile" ON )

# Option to Enable SUN
option( SUN "Enable SUN" OFF )

# Option to Enable WINNT
option( WINNT "Enable WINNT" OFF )

# The lines below will generate the config.h based on the options above
# The file will be in the ${CMAKE_BINARY_DIR} location
set(CONFIG_H ${CMAKE_BINARY_DIR}/config.h)
string(TIMESTAMP CURRENT_TIMESTAMP)
file(WRITE ${CONFIG_H} "/* WARNING: This file is auto-generated by CMake on ${CURRENT_TIMESTAMP}. DO NOT EDIT!!! */\n\n")
if( COVERAGE )
    message(" COVERAGE Enabled")
    file(APPEND ${CONFIG_H} "/* Enable coverage testing */\n")
    file(APPEND ${CONFIG_H} "#define HAVE_COVERAGE \n\n")
endif( COVERAGE )
if( DEBUG )
    message(" DEBUG Enabled")
    file(APPEND ${CONFIG_H} "/* on debugging */\n")
    file(APPEND ${CONFIG_H} "#define HAVE_DEBUG \n\n")
endif( DEBUG )
if( EXTENDED_SPARSE )
    message(" EXTENDED_SPARSE Enabled")
    file(APPEND ${CONFIG_H} "/* extended sparse matrix data types not supported in Matlab */\n")
    file(APPEND ${CONFIG_H} "#define EXTENDED_SPARSE \n\n")
endif( EXTENDED_SPARSE )
if( LINUX )
    message(" LINUX Enabled")
    file(APPEND ${CONFIG_H} "/* Enable LINUX */\n")
    file(APPEND ${CONFIG_H} "#define LINUX \n\n")
endif( LINUX )
if( MAT73 )
    message(" MAT73 Enabled")
    file(APPEND ${CONFIG_H} "/* MAT v7.3 file support */\n")
    file(APPEND ${CONFIG_H} "#define MAT73 \n\n")
endif( MAT73 )
if( PROFILE )
    message(" PROFILE Enabled")
    file(APPEND ${CONFIG_H} "/* on profile */\n")
    file(APPEND ${CONFIG_H} "#define HAVE_PROFILE \n\n")
endif( PROFILE )
if( SUN )
    message(" SUN Enabled")
    file(APPEND ${CONFIG_H} "/* Enable SUN */\n")
    file(APPEND ${CONFIG_H} "#define SUN \n\n")
endif( SUN )
if( WINNT )
    message(" WINNT Enabled")
    file(APPEND ${CONFIG_H} "/* Enable WINNT */\n")
    file(APPEND ${CONFIG_H} "#define WINNT \n\n")
endif( WINNT )

## !!! WARNING These are the defines that were defined regardless of an option.
## !!! Or the script couldn't match them. Match them accordingly, delete them or keep them


# Check what matlab format is used by default
set(DEFAULT_FILE_VERSION "5" CACHE STRING "Default MAT file version (4,5,7.3)")

if (DEFAULT_FILE_VERSION STREQUAL "4")
    set(MAT_FT_DEFAULT MAT_FT_MAT4)
elseif (DEFAULT_FILE_VERSION STREQUAL "5")
    set(MAT_FT_DEFAULT MAT_FT_MAT5)
elseif (DEFAULT_FILE_VERSION STREQUAL "7.3")
    set(MAT_FT_DEFAULT MAT_FT_MAT73)
else()
    message(ERROR "Unrecognized MAT file version")
endif()