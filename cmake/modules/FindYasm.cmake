# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://cmake.org/cmake/help/v4.1/index.html

# Compile YASM assembler library from extern/yasm directory
# This module does NOT search the system - it only uses the local copy

cmake_minimum_required(VERSION 3.15)

# Configuration
set(YASM_ROOT_DIR "${CMAKE_SOURCE_DIR}/extern/yasm")

# Option to enable tests
option(YASM_BUILD_TESTS "Build YASM unit tests" OFF)

# Check that the directory exists
if(NOT EXISTS "${YASM_ROOT_DIR}/libyasm")
    message(FATAL_ERROR "YASM source not found at ${YASM_ROOT_DIR}")
    set(YASM_FOUND FALSE)
    return()
endif()

# Avoid reconfiguring if already done
if(TARGET Yasm::Yasm)
    set(YASM_FOUND TRUE)
    return()
endif()

# ============================================================================
# Configuration checks (simplified from ConfigureChecks.cmake)
# ============================================================================

include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckLibraryExists)

check_include_file(locale.h HAVE_LOCALE_H)
check_include_file(libgen.h HAVE_LIBGEN_H)
check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(direct.h HAVE_DIRECT_H)
check_include_file(stdint.h HAVE_STDINT_H)

check_function_exists(getcwd HAVE_GETCWD)
check_function_exists(toascii HAVE_TOASCII)

check_library_exists(dl dlopen "" HAVE_LIBDL)

if(HAVE_LIBDL)
    set(LIBDL "dl")
else()
    set(LIBDL "")
endif()

# ============================================================================
# Detect YASM version from the source directory
# ============================================================================

set(YASM_VERSION_DEFAULT "1.3.0")

# Try to read version from YASM's version file (if present in release tarballs)
if(EXISTS "${YASM_ROOT_DIR}/version")
    file(STRINGS "${YASM_ROOT_DIR}/version" YASM_VERSION LIMIT_COUNT 1)
    string(STRIP "${YASM_VERSION}" YASM_VERSION)
    if(YASM_VERSION STREQUAL "")
        set(YASM_VERSION "${YASM_VERSION_DEFAULT}")
    endif()
else()
    # Try to detect from git tag (if in a git repository)
    if(EXISTS "${YASM_ROOT_DIR}/.git")
        execute_process(
            COMMAND git describe --match "v[0-9]*" --abbrev=4 HEAD
            WORKING_DIRECTORY "${YASM_ROOT_DIR}"
            OUTPUT_VARIABLE YASM_VERSION_GIT
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE GIT_RESULT
        )
        if(GIT_RESULT EQUAL 0)
            # Remove 'v' prefix and convert dashes to dots
            string(REGEX REPLACE "^v" "" YASM_VERSION "${YASM_VERSION_GIT}")
            string(REPLACE "-" "." YASM_VERSION "${YASM_VERSION}")
        else()
            set(YASM_VERSION "${YASM_VERSION_DEFAULT}")
        endif()
    else()
        # Use default version
        set(YASM_VERSION "${YASM_VERSION_DEFAULT}")
    endif()
endif()

set(PACKAGE_STRING "yasm ${YASM_VERSION}")
set(PACKAGE_VERSION "${YASM_VERSION}")

# Find cpp preprocessor (optional, for error messages only)
find_program(CPP_PROG NAMES cpp)
if(NOT CPP_PROG)
    set(CPP_PROG "cpp")
endif()

# ============================================================================
# Generate configuration headers
# ============================================================================

set(YASM_BINARY_DIR "${CMAKE_BINARY_DIR}/yasm-build")
file(MAKE_DIRECTORY "${YASM_BINARY_DIR}")

# Generate config.h
configure_file(
    "${YASM_ROOT_DIR}/config.h.cmake"
    "${YASM_BINARY_DIR}/config.h"
    @ONLY
)

# Generate libyasm-stdint.h
configure_file(
    "${YASM_ROOT_DIR}/libyasm-stdint.h.cmake"
    "${YASM_BINARY_DIR}/libyasm-stdint.h"
    @ONLY
)

# ============================================================================
# List of libyasm sources (from libyasm/CMakeLists.txt)
# ============================================================================

set(LIBYASM_SOURCES
    ${YASM_ROOT_DIR}/libyasm/assocdat.c
    ${YASM_ROOT_DIR}/libyasm/bitvect.c
    ${YASM_ROOT_DIR}/libyasm/bc-align.c
    ${YASM_ROOT_DIR}/libyasm/bc-data.c
    ${YASM_ROOT_DIR}/libyasm/bc-incbin.c
    ${YASM_ROOT_DIR}/libyasm/bc-org.c
    ${YASM_ROOT_DIR}/libyasm/bc-reserve.c
    ${YASM_ROOT_DIR}/libyasm/bytecode.c
    ${YASM_ROOT_DIR}/libyasm/cmake-module.c
    ${YASM_ROOT_DIR}/libyasm/errwarn.c
    ${YASM_ROOT_DIR}/libyasm/expr.c
    ${YASM_ROOT_DIR}/libyasm/file.c
    ${YASM_ROOT_DIR}/libyasm/floatnum.c
    ${YASM_ROOT_DIR}/libyasm/hamt.c
    ${YASM_ROOT_DIR}/libyasm/insn.c
    ${YASM_ROOT_DIR}/libyasm/intnum.c
    ${YASM_ROOT_DIR}/libyasm/inttree.c
    ${YASM_ROOT_DIR}/libyasm/linemap.c
    ${YASM_ROOT_DIR}/libyasm/md5.c
    ${YASM_ROOT_DIR}/libyasm/mergesort.c
    ${YASM_ROOT_DIR}/libyasm/phash.c
    ${YASM_ROOT_DIR}/libyasm/section.c
    ${YASM_ROOT_DIR}/libyasm/strcasecmp.c
    ${YASM_ROOT_DIR}/libyasm/strsep.c
    ${YASM_ROOT_DIR}/libyasm/symrec.c
    ${YASM_ROOT_DIR}/libyasm/valparam.c
    ${YASM_ROOT_DIR}/libyasm/value.c
    ${YASM_ROOT_DIR}/libyasm/xmalloc.c
    ${YASM_ROOT_DIR}/libyasm/xstrdup.c
)

# ============================================================================
# Create libyasm library
# ============================================================================

add_library(libyasm STATIC ${LIBYASM_SOURCES})

# Modern alias
add_library(Yasm::Yasm ALIAS libyasm)

# Library configuration
target_compile_definitions(libyasm PRIVATE
    HAVE_CONFIG_H
    YASM_LIB_SOURCE
)

# Include directories
target_include_directories(libyasm PUBLIC
    $<BUILD_INTERFACE:${YASM_ROOT_DIR}>
    $<BUILD_INTERFACE:${YASM_ROOT_DIR}/libyasm>
    $<BUILD_INTERFACE:${YASM_BINARY_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Platform-specific compilation options
if(MSVC)
    target_compile_definitions(libyasm PRIVATE
        _CRT_SECURE_NO_WARNINGS
        _CRT_NONSTDC_NO_WARNINGS
    )
elseif(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(libyasm PRIVATE
        -Wall
        -Wno-unused-parameter
    )
endif()

# Target properties
set_target_properties(libyasm PROPERTIES
    OUTPUT_NAME "yasm"
    POSITION_INDEPENDENT_CODE ON
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)

# ============================================================================
# Exported variables
# ============================================================================

# YASM_VERSION is now detected from the source directory (see above)
set(YASM_INCLUDE_DIRS 
    "${YASM_ROOT_DIR}"
    "${YASM_ROOT_DIR}/libyasm"
    "${YASM_BINARY_DIR}"
)
set(YASM_LIBRARIES libyasm)

# Use standard CMake package handling with version support
# This automatically sets Yasm_FOUND based on required vars and version
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Yasm
    REQUIRED_VARS YASM_LIBRARIES YASM_INCLUDE_DIRS YASM_ROOT_DIR
    VERSION_VAR YASM_VERSION
)

# Set uppercase variant for compatibility
set(YASM_FOUND ${Yasm_FOUND})

mark_as_advanced(
    YASM_ROOT_DIR
    YASM_INCLUDE_DIRS
    YASM_LIBRARIES
    YASM_VERSION
)

# ============================================================================
# Unit tests (optional)
# ============================================================================

if(YASM_BUILD_TESTS)
    enable_testing()
    
    # Helper function to create a test
    function(yasm_add_unit_test TEST_NAME SOURCE_FILE)
        add_executable(${TEST_NAME} ${YASM_ROOT_DIR}/libyasm/tests/${SOURCE_FILE})
        
        target_link_libraries(${TEST_NAME} PRIVATE libyasm)
        
        target_include_directories(${TEST_NAME} PRIVATE
            ${YASM_ROOT_DIR}
            ${YASM_ROOT_DIR}/libyasm
            ${YASM_BINARY_DIR}
        )
        
        target_compile_definitions(${TEST_NAME} PRIVATE HAVE_CONFIG_H)
        
        if(MSVC)
            target_compile_definitions(${TEST_NAME} PRIVATE
                _CRT_SECURE_NO_WARNINGS
                _CRT_NONSTDC_NO_WARNINGS
            )
        endif()
        
        add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
        
        set_target_properties(${TEST_NAME} PROPERTIES
            FOLDER "Tests/YASM"
        )
    endfunction()
    
    # Add unit tests
    yasm_add_unit_test(bitvect_test bitvect_test.c)
    yasm_add_unit_test(floatnum_test floatnum_test.c)
    yasm_add_unit_test(leb128_test leb128_test.c)
    yasm_add_unit_test(splitpath_test splitpath_test.c)
    yasm_add_unit_test(combpath_test combpath_test.c)
    yasm_add_unit_test(uncstring_test uncstring_test.c)
    
    message(STATUS "YASM tests enabled - use 'ctest' to run tests")
endif()

# ============================================================================
# Additional status message
# ============================================================================

if(YASM_FOUND AND NOT Yasm_FIND_QUIETLY)
    message(STATUS "YASM configuration:")
    message(STATUS "  Build tests: ${YASM_BUILD_TESTS}")
endif()