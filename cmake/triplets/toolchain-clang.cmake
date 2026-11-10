# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Doc: https://learn.microsoft.com/en-us/vcpkg/users/triplets#vcpkg_chainload_toolchain_file

# Same compiler as the presets, so that vcpkg ports and the engine share one ABI.
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
