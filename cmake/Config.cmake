# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html


# ==============================================================================================================
# User-Configurable Options
# ==============================================================================================================
# These options can be easily overridden via command line (e.g., cmake -DBUILD_TESTS=OFF)

# Library Build Type
option(BUILD_SHARED_LIBS "Build shared libraries instead of static" ON)

# Feature Toggles
option(BUILD_TESTS "Enable building tests" OFF)
option(BUILD_EXAMPLES "Enable building examples" OFF)
option(ENABLE_DEBUG "Enable debug mode with extra logging" OFF)
option(ENABLE_CPP20_MODULE "Enable C++ 20 module support for Vulkan" OFF)

# Dependency Management
option(USE_SYSTEM_LIBS "Use system-installed libraries instead of bundled" OFF)
option(GIT_SUBMODULE_UPDATE "Update and initialize Git submodules during build" ON)

# Runtime Configuration
option(ENABLE_RUNTIMES "Enable UV and Python runtime configuration (Windows only)" OFF)

# Tooling
option(CMAKE_EXPORT_COMPILE_COMMANDS "Export compile_commands.json for tools (clangd, clang-tidy, VSCode)" OFF)


# ==============================================================================================================
# C Language Settings
# ==============================================================================================================

# Specify the C language standard to use for all targets.
# This controls the C dialect used by the compiler (for example: 11, 17, 23).
set(CMAKE_C_STANDARD 23 CACHE STRING "C language standard (e.g. 23)")

# Require that the compiler fully supports the requested C standard.
# When ON, CMake will error if the compiler cannot provide the requested standard.
set(CMAKE_C_STANDARD_REQUIRED ON CACHE BOOL "Require C Standard")

# Disable compiler-specific extensions; enforce strict ISO C compliance.
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "Enable compiler-specific extensions (GNU/MSVC). OFF = strict ISO C.")


# ==============================================================================================================
# C++ Language Settings
# ==============================================================================================================

# Specify the C++ language standard to use for all targets.
# This controls the C++ dialect used by the compiler (for example: 11, 17, 20, 23).
set(CMAKE_CXX_STANDARD 23 CACHE STRING "C++ language standard (e.g. 23)")

# Require that the compiler fully supports the requested C++ standard.
# When ON, CMake will error if the compiler cannot provide the requested standard.
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "Require C++ Standard")

# Disable compiler-specific extensions; enforce strict ISO C++ compliance.
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "Enable compiler-specific extensions (GNU/MSVC). OFF = strict ISO C++.")


# ==============================================================================================================
# Conditional Logic Based on Options
# ==============================================================================================================

# Enable debug mode definitions if requested
if(ENABLE_DEBUG)
    add_compile_definitions(DEBUG_MODE)
    message(STATUS "Debug mode enabled with DEBUG_MODE definition")
endif()

# Enable C++ module dependency scanning only if C++ 20 module is enable
if(ENABLE_CPP20_MODULE)
    set(CMAKE_CXX_SCAN_FOR_MODULES ON)
endif()

# Platform-specific tweaks
if(WIN32)
    # Windows-specific options can be added here
    message(STATUS "Configuring for Windows platform")
elseif(UNIX)
    # Unix-specific options can be added here
    message(STATUS "Configuring for Unix platform")
endif()

# ==============================================================================================================
# Project Settings                      
# ==============================================================================================================

set(AETHER_ENGINE_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE STRING "Root directory of the AetherEngine project")

set(AETHER_ENGINE_ASSETS_DIR "${AETHER_ENGINE_PROJECT_DIR}/assets" CACHE STRING "Directory for project assets")
set(AETHER_ENGINE_CACHE_DIR "${AETHER_ENGINE_PROJECT_DIR}/.cache" CACHE STRING "Directory for build cache")
set(AETHER_ENGINE_CONFIGS_DIR "${AETHER_ENGINE_PROJECT_DIR}/configs" CACHE STRING "Directory for configuration files")
set(AETHER_ENGINE_EXAMPLES_DIR "${AETHER_ENGINE_PROJECT_DIR}/examples" CACHE STRING "Directory for example projects")
set(AETHER_ENGINE_DOCS_DIR "${AETHER_ENGINE_PROJECT_DIR}/docs" CACHE STRING "Directory for documentation")
set(AETHER_ENGINE_EXTERN_DIR "${AETHER_ENGINE_PROJECT_DIR}/extern" CACHE STRING "Directory for external dependencies")
set(AETHER_ENGINE_RUNTIMES_DIR "${AETHER_ENGINE_PROJECT_DIR}/runtimes" CACHE STRING "Directory for runtime configurations")
set(AETHER_ENGINE_SHADERS_DIR "${AETHER_ENGINE_ASSETS_DIR}/shaders" CACHE STRING "Directory for shader files")
set(AETHER_ENGINE_SOURCE_DIR "${AETHER_ENGINE_PROJECT_DIR}/sources" CACHE STRING "Directory for source code")
set(AETHER_ENGINE_TESTS_DIR "${AETHER_ENGINE_PROJECT_DIR}/tests" CACHE STRING "Directory for test files")
set(AETHER_ENGINE_TEXTURES_DIR "${AETHER_ENGINE_ASSETS_DIR}/textures" CACHE STRING "Directory for texture assets")

# UV Settings (For Python environment and dependency management)
set(AETHER_ENGINE_UV_RUNTIME_DIR "${AETHER_ENGINE_RUNTIMES_DIR}/uv" CACHE STRING "Directory for UV runtime")
set(AETHER_ENGINE_UV_CACHE_DIR "${AETHER_ENGINE_CACHE_DIR}/uv")
set(AETHER_ENGINE_UV_VERSION "0.9.27" CACHE STRING "Version of the UV runtime used by the project (e.g., 0.9.27)")

# Python Settings (Runtime and version configuration)
set(AETHER_ENGINE_PYTHON_RUNTIME_DIR "${AETHER_ENGINE_RUNTIMES_DIR}/python" CACHE STRING "Directory for Python runtime")
set(AETHER_ENGINE_PYTHON_CACHE_DIR "${AETHER_ENGINE_CACHE_DIR}/python")
set(AETHER_ENGINE_PYTHON_VERSION "3.14" CACHE STRING "Python version used by the project.")