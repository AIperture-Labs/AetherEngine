# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0

# aether_core_tests: unit tests of the core module.
message(STATUS "Configuring aether_core_tests")

add_doctest(
    NAME aether_core_tests
    SOURCES
        assert.test.cpp
        error.test.cpp
        logger.test.cpp
        types.test.cpp
        version.test.cpp
    LIBS AetherEngine::core
)

# The child process that fails on purpose, run by assert.test.cpp.
add_executable(aether_core_assert_helper assert_helper.cpp)
target_link_libraries(aether_core_assert_helper PRIVATE AetherEngine::core)
enable_warnings(aether_core_assert_helper)
add_dependencies(aether_core_tests aether_core_assert_helper)
target_compile_definitions(aether_core_tests PRIVATE "AETHER_ASSERT_HELPER=\"$<TARGET_FILE:aether_core_assert_helper>\"")
