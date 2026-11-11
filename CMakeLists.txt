# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

cmake_minimum_required(VERSION 3.31...4.1)

project(
    AetherEngine
    VERSION 0.1.0
    LANGUAGES CXX
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/helpers")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

include(Config)
include(BuildProfile)
include(CompilerWarnings)
include(CompileCommands)
include(Coverage)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Hidden by default so that only symbols marked by each module's generated export macro are public;
# the shared and static builds then expose the same interface.
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

if(AETHER_EXPORT_COMPILE_COMMANDS)
    link_compile_commands()
endif()

add_subdirectory(sources)

if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

add_coverage_target()
