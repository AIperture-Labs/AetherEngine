# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
#   - https://llvm.org/docs/CommandGuide/llvm-cov.html

# enable_coverage(<target>)
#
# Instrument <target> when AETHER_COVERAGE is on. Called by every first-party target and never by the
# dependencies, which vcpkg builds on its own. AETHER_COVERAGE is also defined on <target>, for the code that
# must write its profile before the process dies (see assertionFailed()).
function(enable_coverage target)
    if(NOT AETHER_COVERAGE)
        return()
    endif()
    target_compile_options(${target} PRIVATE -fprofile-instr-generate -fcoverage-mapping)
    target_link_options(${target} PRIVATE -fprofile-instr-generate)
    target_compile_definitions(${target} PRIVATE AETHER_COVERAGE)
    set_property(GLOBAL APPEND PROPERTY AETHER_COVERAGE_TARGETS ${target})
endfunction()

# add_coverage_target()
#
# Define the `coverage` target, once every first-party target is declared: it runs the tests, then prints the
# report of sources/, writes the HTML one and checks the thresholds (cmake/helpers/CoverageReport.cmake).
function(add_coverage_target)
    if(NOT AETHER_COVERAGE)
        return()
    endif()
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        message(FATAL_ERROR "AETHER_COVERAGE needs Clang, not '${CMAKE_CXX_COMPILER_ID}'")
    endif()
    if(NOT BUILD_TESTS)
        message(FATAL_ERROR "AETHER_COVERAGE needs BUILD_TESTS=ON: the coverage comes from the tests")
    endif()

    # The tools of the same LLVM as the compiler, next to it.
    file(REAL_PATH "${CMAKE_CXX_COMPILER}" compiler)
    get_filename_component(llvm_bin "${compiler}" DIRECTORY)
    string(REGEX MATCH "^[0-9]+" llvm_major "${CMAKE_CXX_COMPILER_VERSION}")
    foreach(tool llvm-cov llvm-profdata)
        find_program(
            AETHER_${tool} ${tool}-${llvm_major} ${tool}
            HINTS "${llvm_bin}"
            NO_DEFAULT_PATH
        )
        find_program(AETHER_${tool} ${tool} REQUIRED)
        message(STATUS "Coverage: ${tool} is ${AETHER_${tool}}")
    endforeach()

    get_property(targets GLOBAL PROPERTY AETHER_COVERAGE_TARGETS)
    set(objects "")
    foreach(target IN LISTS targets)
        get_target_property(type ${target} TYPE)
        if(type STREQUAL "EXECUTABLE" OR type STREQUAL "SHARED_LIBRARY")
            string(APPEND objects "$<TARGET_FILE:${target}>|")
        endif()
    endforeach()

    add_custom_target(
        coverage
        COMMAND
            "${CMAKE_COMMAND}"
            "-DBUILD_DIR=${CMAKE_BINARY_DIR}"
            "-DSOURCE_DIR=${CMAKE_SOURCE_DIR}"
            "-DCTEST=${CMAKE_CTEST_COMMAND}"
            "-DLLVM_COV=${AETHER_llvm-cov}"
            "-DLLVM_PROFDATA=${AETHER_llvm-profdata}"
            "-DOBJECTS=${objects}"
            "-DMIN_LINES=${AETHER_COVERAGE_MIN_LINES}"
            "-DMIN_FUNCTIONS=${AETHER_COVERAGE_MIN_FUNCTIONS}"
            "-DMIN_BRANCHES=${AETHER_COVERAGE_MIN_BRANCHES}"
            -P "${CMAKE_SOURCE_DIR}/cmake/helpers/CoverageReport.cmake"
        DEPENDS ${targets}
        USES_TERMINAL
        VERBATIM
        COMMENT "Measuring the code coverage"
    )
endfunction()
