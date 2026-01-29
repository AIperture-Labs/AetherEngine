# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# Export compile commands for tooling (e.g., clangd, clang-tidy, VSCode)
option(CMAKE_EXPORT_COMPILE_COMMANDS "Export compile_commands.json for tools (clangd, clang-tidy, VSCode)" OFF)

# C Settings =========================================================================================================
# Specify the C language standard to use for all targets.
# This controls the C dialect used by the compiler (for example: 11, 17, 23).
set(CMAKE_C_STANDARD 23 CACHE STRING "C language standard (e.g. 23)")

# Require that the compiler fully supports the requested C standard.
# When ON, CMake will error if the compiler cannot provide the requested standard.
set(CMAKE_C_STANDARD_REQUIRED ON CACHE BOOL "Require C Standard")

# Disable compiler-specific extensions; enforce strict ISO C compliance.
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "Enable compiler-specific extensions (GNU/MSVC). OFF = strict ISO C.")


# C++ Settings =======================================================================================================
# Specify the C++ language standard to use for all targets.
# This controls the C++ dialect used by the compiler (for example: 11, 17, 20, 23).
set(CMAKE_CXX_STANDARD 23 CACHE STRING "C++ language standard (e.g. 23)")

# Require that the compiler fully supports the requested C++ standard.
# When ON, CMake will error if the compiler cannot provide the requested standard.
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "Require C++ Standard")

# Disable compiler-specific extensions; enforce strict ISO C++ compliance.
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "Enable compiler-specific extensions (GNU/MSVC). OFF = strict ISO C++.")