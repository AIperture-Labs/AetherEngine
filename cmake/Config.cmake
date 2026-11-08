# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/variable/BUILD_SHARED_LIBS.html

# Standard CMake switch, read by every add_library() without an explicit kind.
option(BUILD_SHARED_LIBS "Build the engine modules as shared libraries" OFF)
