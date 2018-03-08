enable_testing()

add_executable(test_mat ${PROJECT_SOURCE_DIR}/matio/test/test_mat.c)
target_link_libraries(test_mat matio)

add_executable(test_snprintf ${PROJECT_SOURCE_DIR}/matio/test/test_snprintf.c)
target_link_libraries(test_snprintf matio)

option(MATLAB_TESTING "Enable matlab read tests (requires a function matlab)" OFF)
if (MATLAB_TESTING)
    find_program(MATLAB matlab)
else()
    set(MATLAB FALSE)
endif()

macro(PARSE_TEST_ARGUMENTS LIST_VARS DEFAULT_VAR)
    unset(${DEFAULT_VAR})
    foreach(var ${LIST_VARS})
        unset(${var})
    endforeach ()

    set(CURRENT_VAR ${DEFAULT_VAR})
    foreach (arg ${ARGN})
        set(skip_this_arg FALSE)
        foreach(var ${LIST_VARS})
            if (${arg} STREQUAL ${var})
                set(CURRENT_VAR ${var})
                set(skip_this_arg TRUE)
                break()
            endif()
        endforeach ()
        if (NOT skip_this_arg)
            set(${CURRENT_VAR} ${${CURRENT_VAR}} ${arg})
        endif()
    endforeach ()
endmacro()

# TEST_DIR is the place where to find the test executables
if (WIN32)
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug)
    endif()
    set(TEST_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
else()
    set(TEST_DIR ${CMAKE_CURRENT_BINARY_DIR})
endif()

set(TMP_DIR ${TEST_DIR}/tmp)
file(MAKE_DIRECTORY ${TMP_DIR})

macro(MATIO_TEST_READ NAME REFERENCE PROG_NAME)
    PARSE_TEST_ARGUMENTS("DEPENDS" "DEFAULT" ${ARGN})
    set(PROG_ARGS "${DEFAULT}")
    SEPARATE_ARGUMENTS(ARGS UNIX_COMMAND "${PROG_ARGS}")
    set(EXECUTABLE ${TEST_DIR}/${PROG_NAME}${CMAKE_EXECUTABLE_SUFFIX})
    set(OUTPUT ${NAME}.out)
    add_test(${NAME} ${EXECUTABLE} ${PROG_ARGS} -o ${TMP_DIR}/${OUTPUT}) # To perform memcheck tests
    if (DEPENDS)
        set_tests_properties(${NAME} PROPERTIES DEPENDS "${DEPENDS}")
    endif()
    add_test(${NAME}-COMPARISON
             ${CMAKE_COMMAND} -D TEST_OUTPUT:STRING=${TMP_DIR}/${OUTPUT}
                              -D TEST_REFERENCE_DIR:STRING=${PROJECT_SOURCE_DIR}/matio/test/results
                              -D TEST_RESULT:STRING=${REFERENCE}
                              -P ${PROJECT_SOURCE_DIR}/cmake/runTest.cmake) # To compare output to reference file

    #  Add a dependency to the MATIO-matlab test so that COMPARISON tests are run after matlab ones (so they do not
    #  cleanup the files too early).
    if (MATLAB)
        string(REPLACE "MATIO-" "MATIO-matlab" MATDEPENDS ${NAME})
        set_tests_properties(${NAME}-COMPARISON PROPERTIES DEPENDS ${MATDEPENDS})
    endif()
    set_tests_properties(${NAME}-COMPARISON PROPERTIES
                         DEPENDS ${NAME}
                         PASS_REGULAR_EXPRESSION "Success")
endmacro()

set(MATIO_FILES)
macro(MATIO_TEST_WRITE NAME FILENAME PROG_NAME)
    PARSE_TEST_ARGUMENTS("DEPENDS" "DEFAULT" ${ARGN})
    set(PROG_ARGS "${DEFAULT}")
    SEPARATE_ARGUMENTS(ARGS UNIX_COMMAND "${PROG_ARGS}")
    set(EXECUTABLE ${TEST_DIR}/${PROG_NAME}${CMAKE_EXECUTABLE_SUFFIX})
    set(MATIO_FILES ${MATIO_FILES} ${FILENAME})
    add_test(${NAME} ${EXECUTABLE} ${PROG_ARGS} -o ${TMP_DIR}/${FILENAME}) # To perform memcheck tests
endmacro()

macro(MATIO_TEST_MATLAB_READ NAME FILE TEST_TYPE CLASS)
    if (MATLAB)
        PARSE_TEST_ARGUMENTS("DEPENDS" "DEFAULT" ${ARGN})
        SET_TEST_DIR(TEST_DIR)
        string(REPLACE "-" "_" MSBNAME ${FILE})
        string(REPLACE ".mat" "" MSBNAME ${MSBNAME})
        string(REPLACE "." "_" MSBNAME ${MSBNAME})
        set(FILENAME ${TEST_DIR}/${FILE})
        set(TYPE ${CLASS})
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/matlab_${TEST_TYPE}.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/matlab/${MSBNAME}.m @ONLY)
        add_test(NAME ${NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/matlab COMMAND ${MATLAB} -nosplash -nojvm -r "${MSBNAME};exit")
        if (DEPENDS)
            set_tests_properties(${NAME} PROPERTIES DEPENDS ${DEPENDS})
        endif()
        set_tests_properties(${NAME} PROPERTIES PASS_REGULAR_EXPRESSION "PASSED")
    endif()
endmacro()

set(v4_vars var1 var11 var24)
set(vars)
foreach(i RANGE 1 69)
    set(vars ${vars} "var${i}")
endforeach()
set(compressed_vars ${vars})
set(uncompressed_vars ${vars})

set(HDFTESTS)
if (MAT73)
    # XXX don't test HDF5 as files are missing
    # set(HDFTESTS hdf)
    # set(hdf_vars ${vars})
    # set(special_vars var23 var27 var52 var66)
endif()

foreach(vers v4 compressed uncompressed ${HDFTESTS})
    foreach(endian le be)
        foreach(var ${${vers}_vars})
            set(MODIFIER)
            if (${vers} STREQUAL hdf)
                list(FIND special_vars ${var} special)
                if (NOT ${special} EQUAL -1)
                    set(MODIFIER -hdf)
                endif()
            endif()
            set(testname read-${vers}-${endian}-${var})
            set(input ${CMAKE_CURRENT_SOURCE_DIR}/matio/test/datasets/matio_test_cases_${vers}_${endian}.mat)
            set(reference read-${var}${MODIFIER}.out)
            MATIO_TEST_READ(MATIO-${testname} ${reference} test_mat readvar ${input} ${var})
        endforeach()
    endforeach()
endforeach()
