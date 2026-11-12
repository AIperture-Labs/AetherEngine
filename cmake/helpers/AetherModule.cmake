# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/command/add_library.html
#   - https://cmake.org/cmake/help/v4.1/module/GenerateExportHeader.html

include(GenerateExportHeader)

# aether_add_module(<name> [CONTENT] [INCLUDE_PREFIX <directory>] SOURCES <source>...)
#
# Declare the module <name>: a library built in the mode of the engine, in C++23, with hidden symbols and an
# export macro. The public API of the engine's build: an engine module, a plugin and the content of a project
# outside the engine tree are all declared with it. Dependencies are added with target_link_libraries().
#
# - Public headers are in include/, next to the calling CMakeLists.txt.
# - <NAME>_API, from the generated <INCLUDE_PREFIX>/export.hpp, marks the exported symbols. INCLUDE_PREFIX
#   defaults to <name>.
# - CONTENT: the content of a project (docs/architecture.md). In dynamic mode (BUILD_SHARED_LIBS), a library
#   that a host loads at run time and nothing links; in monolithic mode, a static library like any module.
#   The kind follows the mode of the engine only: a static engine never gets content loaded at run time,
#   which would carry its own copy of the engine state.
function(aether_add_module name)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "CONTENT" "INCLUDE_PREFIX" "SOURCES")
    if(NOT ARG_INCLUDE_PREFIX)
        set(ARG_INCLUDE_PREFIX "${name}")
    endif()

    # Without a kind, add_library() follows BUILD_SHARED_LIBS.
    set(kind "")
    if(ARG_CONTENT AND BUILD_SHARED_LIBS)
        set(kind MODULE)
    endif()
    add_library(${name} ${kind} ${ARG_SOURCES})

    target_compile_features(${name} PUBLIC cxx_std_23)
    # Hidden by default so that only the symbols marked <NAME>_API are public; the shared and static builds
    # then expose the same interface.
    set_target_properties(
        ${name}
        PROPERTIES
            CXX_EXTENSIONS OFF
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN ON
    )

    string(TOUPPER "${name}" upper_name)
    generate_export_header(
        ${name}
        BASE_NAME ${upper_name}
        EXPORT_MACRO_NAME ${upper_name}_API
        EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/include/${ARG_INCLUDE_PREFIX}/export.hpp"
    )
    target_include_directories(
        ${name}
        PUBLIC
            "${CMAKE_CURRENT_SOURCE_DIR}/include"
            "${CMAKE_CURRENT_BINARY_DIR}/include"
    )
endfunction()
