# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://cmake.org/cmake/help/v4.1/index.html

cmake_minimum_required(VERSION 3.31..4.1)

project(
    AetherEngine
    VERSION 0.1.0
    LANGUAGES C CXX
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")

include(configs)

# add_subdirectory(${AETHER_ENGINE_SOURCE_DIR})
# add_subdirectory(${AETHER_ENGINE_TESTS_DIR})
# add_subdirectory(${AETHER_ENGINE_DOCS_DIR})
# add_subdirectory(${AETHER_ENGINE_SHADERS_DIR})
# add_subdirectory(${AETHER_ENGINE_TEXTURES_DIR})
