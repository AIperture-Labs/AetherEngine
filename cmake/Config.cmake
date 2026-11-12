# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/variable/BUILD_SHARED_LIBS.html
#   - https://cmake.org/cmake/help/v4.1/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html

# Standard CMake switch, read by every add_library() without an explicit kind.
option(BUILD_SHARED_LIBS "Build the engine modules as shared libraries" OFF)

# Written to the build directory, then linked at the root by aether_link_compile_commands() for language servers.
# A project option drives it: CMake creates an empty CMAKE_EXPORT_COMPILE_COMMANDS cache entry before this
# file runs, so an option() of that name would never apply its default.
option(AETHER_EXPORT_COMPILE_COMMANDS "Export compile_commands.json for language servers and clang-tidy" ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ${AETHER_EXPORT_COMPILE_COMMANDS})

option(BUILD_TESTS "Build the unit tests and register them with CTest" OFF)

# Executables and shared libraries side by side: on Windows, a test finds the engine's DLLs only there.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# What is compiled in or out (logs, assertions, validation), independent of CMAKE_BUILD_TYPE (optimisation).
# See aether_apply_build_profile() in cmake/helpers/BuildProfile.cmake.
set(AETHER_BUILD_PROFILE "Debug" CACHE STRING "Build profile: Debug, Development or Shipping")
set_property(CACHE AETHER_BUILD_PROFILE PROPERTY STRINGS Debug Development Shipping)

# See aether_enable_coverage() and aether_add_coverage_target() in cmake/helpers/Coverage.cmake.
option(AETHER_COVERAGE "Measure the code coverage of the first-party targets (Clang, source-based)" OFF)

# The minimum coverage, in percent, below which the coverage target fails. The one place to change them.
set(AETHER_COVERAGE_MIN_LINES 85 CACHE STRING "Minimum line coverage, in percent")
set(AETHER_COVERAGE_MIN_FUNCTIONS 90 CACHE STRING "Minimum function coverage, in percent")
set(AETHER_COVERAGE_MIN_BRANCHES 75 CACHE STRING "Minimum branch coverage, in percent")
