# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://github.com/doctest/doctest/blob/master/doc/markdown/main.md
#   - https://github.com/doctest/doctest/blob/master/doc/markdown/commandline.md

# The doctest.cmake of the vcpkg port, which provides doctest_discover_tests().
find_package(doctest CONFIG REQUIRED)
include("${doctest_DIR}/doctest.cmake")

# aether_add_doctest(NAME <name> SOURCES <source>... [LIBS <library>...])
#
# Build the test executable <name> from SOURCES, link it with doctest and LIBS, and register each of its
# test cases with CTest as "<name>/<test case>".
function(aether_add_doctest)
    cmake_parse_arguments(ARG "" "NAME" "SOURCES;LIBS" ${ARGN})

    # The sources include doctest.h without defining main(); this one file does it once per executable.
    set(main_source "${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}_main.cpp")
    file(
        CONFIGURE
        OUTPUT "${main_source}"
        CONTENT "#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN\n#include <doctest/doctest.h>\n"
    )

    add_executable(${ARG_NAME} "${main_source}" ${ARG_SOURCES})
    target_link_libraries(${ARG_NAME} PRIVATE doctest::doctest ${ARG_LIBS})
    aether_enable_warnings(${ARG_NAME})
    aether_enable_coverage(${ARG_NAME})
    doctest_discover_tests(${ARG_NAME} TEST_PREFIX "${ARG_NAME}/")
endfunction()
