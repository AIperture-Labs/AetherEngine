# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

cmake_minimum_required(VERSION 3.31...4.1)

project(
    AetherEngine
    VERSION 0.1.0
    LANGUAGES C CXX
)

# Configure CMake module paths
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/helpers")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

# Add cmake/modules to prefix path for CONFIG mode package discovery
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

include(Config)
include(CompilerWarnings)
include(Dependencies)

# add_subdirectory(${AETHER_ENGINE_SOURCE_DIR})
# add_subdirectory(${AETHER_ENGINE_TESTS_DIR})
# add_subdirectory(${AETHER_ENGINE_DOCS_DIR})
# add_subdirectory(${AETHER_ENGINE_SHADERS_DIR})
# add_subdirectory(${AETHER_ENGINE_TEXTURES_DIR})
