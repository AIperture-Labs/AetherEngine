# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Contributors:
#   Copyright (c) 2026 Claude Code (Claude Sonnet 5.5)
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
include(CompilerWarnings)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Hidden by default so that only symbols marked by each module's generated export macro are public;
# the shared and static builds then expose the same interface.
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# clangd looks for the database at the repository root, while it is generated in the build directory.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
file(
    CREATE_LINK
    "${CMAKE_BINARY_DIR}/compile_commands.json"
    "${CMAKE_SOURCE_DIR}/compile_commands.json"
    SYMBOLIC
    RESULT COMPILE_COMMANDS_LINK_RESULT
)
# Creating a symlink can be denied (e.g. on Windows without Developer Mode); that must not stop the configure.
if(NOT COMPILE_COMMANDS_LINK_RESULT EQUAL 0)
    message(
        WARNING
        "Cannot link compile_commands.json at the root (${COMPILE_COMMANDS_LINK_RESULT}): "
        "clangd will not find it"
    )
endif()
