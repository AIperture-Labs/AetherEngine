# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/variable/BUILD_SHARED_LIBS.html
#   - https://cmake.org/cmake/help/v4.1/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html

# Standard CMake switch, read by every add_library() without an explicit kind.
option(BUILD_SHARED_LIBS "Build the engine modules as shared libraries" OFF)

# Written to the build directory, then linked at the root by link_compile_commands() for language servers.
# A project option drives it: CMake creates an empty CMAKE_EXPORT_COMPILE_COMMANDS cache entry before this
# file runs, so an option() of that name would never apply its default.
option(AETHER_EXPORT_COMPILE_COMMANDS "Export compile_commands.json for language servers and clang-tidy" ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ${AETHER_EXPORT_COMPILE_COMMANDS})

option(BUILD_TESTS "Build the unit tests and register them with CTest" OFF)

# Executables, shared libraries and loadable content side by side: on Windows, a test finds the engine's DLLs
# only there, and on every platform each library is found, and loaded, once (docs/architecture.md).
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# What is compiled in or out (logs, assertions, validation), independent of CMAKE_BUILD_TYPE (optimisation).
# See apply_build_profile() in cmake/helpers/BuildProfile.cmake.
set(AETHER_BUILD_PROFILE "Debug" CACHE STRING "Build profile: Debug, Development or Shipping")
set_property(CACHE AETHER_BUILD_PROFILE PROPERTY STRINGS Debug Development Shipping)
