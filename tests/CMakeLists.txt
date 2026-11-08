# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/manual/ctest.1.html

# Unit tests, one directory per module under test.
message(STATUS "Configuring tests")

include(Doctest)

add_subdirectory(core)
