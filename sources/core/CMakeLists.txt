# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/module/GenerateExportHeader.html
#   - https://github.com/g-truc/glm/blob/master/manual.md

# aether_core: fundamental types, version, logger and assertions of the engine.
message(STATUS "Configuring aether_core")

find_package(glm CONFIG REQUIRED)

add_library(
    aether_core
    src/assert.cpp
    src/logger.cpp
    src/version.cpp
)
add_library(AetherEngine::core ALIAS aether_core)

include(GenerateExportHeader)
generate_export_header(
    aether_core
    BASE_NAME AETHER_CORE
    EXPORT_MACRO_NAME AETHER_CORE_API
    EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/include/aether/core/export.hpp"
)
# The version comes from project() only.
configure_file(
    include/aether/core/version.hpp.in
    "${CMAKE_CURRENT_BINARY_DIR}/include/aether/core/version.hpp"
    @ONLY
)

target_include_directories(
    aether_core
    PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
        "${CMAKE_CURRENT_BINARY_DIR}/include"
)
target_link_libraries(aether_core PUBLIC glm::glm)
apply_build_profile(aether_core)
enable_warnings(aether_core)
enable_coverage(aether_core)
