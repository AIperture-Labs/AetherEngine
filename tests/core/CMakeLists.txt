# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0

# aether_core_tests: unit tests of the core module.
message(STATUS "Configuring aether_core_tests")

add_doctest(
    NAME aether_core_tests
    SOURCES
        error.test.cpp
        logger.test.cpp
        types.test.cpp
        version.test.cpp
    LIBS AetherEngine::core
)
