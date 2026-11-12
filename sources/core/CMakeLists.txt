# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://github.com/g-truc/glm/blob/master/manual.md

# aether_core: fundamental types, version, logger and assertions of the engine.
message(STATUS "Configuring aether_core")

find_package(glm CONFIG REQUIRED)

aether_add_engine_module(
    core
    SOURCES
        src/assert.cpp
        src/logger.cpp
        src/version.cpp
)

# The version comes from project() only.
configure_file(
    include/aether/core/version.hpp.in
    "${CMAKE_CURRENT_BINARY_DIR}/include/aether/core/version.hpp"
    @ONLY
)

target_link_libraries(aether_core PUBLIC glm::glm)
# Every module links core, which carries the build profile to all of them.
apply_build_profile(aether_core)
