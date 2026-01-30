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
option(FORCE_DOWNLOAD_DEPS "Force download and extraction of dependencies, even if they are already present" OFF)

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
# Code Generation
# ==============================================================================================================

# TODO: Re-evaluate enabling PIC after performance benchmarking in production builds.
# Note: PIC (Position Independent Code) has a minor performance overhead (~3-5%) on x86_64,
# but enables better address space layout randomization (ASLR). Consider enabling for security-critical deployments.
option(CMAKE_POSITION_INDEPENDENT_CODE "Generate Position Independent Code (PIC). Enables code to be loaded at any memory address. Currently OFF for performance." OFF)

# Link-Time Optimization: Analyzes and optimizes code across translation unit boundaries.
# Trade-off: Increases compile time significantly but can improve runtime performance (5-15% depending on workload).
# Useful for release builds; recommend disabling for debug builds to speed up iteration.
option(CMAKE_INTERPROCEDURAL_OPTIMIZATION "Enable Link-Time Optimization (LTO) for better code optimization across compilation units" OFF)


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

# Tooling configuration - Setup compile_commands.json symlink/copy if export is enabled
if(CMAKE_EXPORT_COMPILE_COMMANDS)
    setup_compile_commands_symlink()
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

# ==============================================================================================================
# GLM Library Options
# ==============================================================================================================
# These options and variables control the behavior of the GLM math library.
# See: extern\glm\manual.md

option(GLM_BUILD_LIBRARY "Build dynamic/static library" ON)
option(GLM_BUILD_TESTS "Build the test programs" OFF)
option(GLM_BUILD_INSTALL "Generate the install target" ON)
option(GLM_ENABLE_CXX_98 "Enable C++ 98" OFF)
option(GLM_ENABLE_CXX_11 "Enable C++ 11" OFF)
option(GLM_ENABLE_CXX_14 "Enable C++ 14" OFF)
option(GLM_ENABLE_CXX_17 "Enable C++ 17" OFF)
option(GLM_ENABLE_CXX_20 "Enable C++ 20" ON)
option(GLM_ENABLE_LANG_EXTENSIONS "Enable language extensions" OFF)
option(GLM_DISABLE_AUTO_DETECTION "Disable platform, compiler, arch and C++ language detection" OFF)
option(GLM_ENABLE_FAST_MATH "Enable fast math optimizations" ON)
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64|i[3-6]86)$")
    option(GLM_ENABLE_SIMD_SSE2 "Enable SSE2 optimizations" ON)
    option(GLM_ENABLE_SIMD_SSE3 "Enable SSE3 optimizations" ON)
    option(GLM_ENABLE_SIMD_SSSE3 "Enable SSSE3 optimizations" ON)
    option(GLM_ENABLE_SIMD_SSE4_1 "Enable SSE 4.1 optimizations" ON)
    option(GLM_ENABLE_SIMD_SSE4_2 "Enable SSE 4.2 optimizations" ON)
    option(GLM_ENABLE_SIMD_AVX "Enable AVX optimizations" ON)
    option(GLM_ENABLE_SIMD_AVX2 "Enable AVX2 optimizations" ON)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm|aarch64)")
    option(GLM_ENABLE_SIMD_NEON "Enable ARM NEON optimizations" OFF)
endif()
option(GLM_FORCE_PURE "Force 'pure' instructions" OFF)
option(GLM_QUIET "Suppress GLM status messages" OFF)

# ==============================================================================================================
# YASM Assembler Options
# ==============================================================================================================
# These options control the build and features of the YASM assembler (extern/yasm).
# See: extern/yasm/CMakeLists.txt

option(YASM_BUILD_SHARED_LIBS "Build YASM as shared libraries instead of static" OFF)
option(ENABLE_NLS "Enable Native Language Support (NLS) for YASM" OFF)
option(YASM_BUILD_TESTS "Build YASM test suite" OFF)

# ==============================================================================================================
# libjpeg-turbo Options
# ==============================================================================================================
# These options control the build and features of libjpeg-turbo (extern/libjpeg-turbo).
# See: extern/libjpeg-turbo/CMakeLists.txt and extern/libjpeg-turbo/BUILDING.md

# Library Build Options
option(JPEG_ENABLE_SHARED "Build libjpeg-turbo shared libraries" ON)
option(JPEG_ENABLE_STATIC "Build libjpeg-turbo static libraries" ON)

# API/ABI Emulation Options
option(JPEG_WITH_JPEG7 "Emulate libjpeg v7 API/ABI (backward-incompatible with v6b)" OFF)
option(JPEG_WITH_JPEG8 "Emulate libjpeg v8 API/ABI (backward-incompatible with v6b)" OFF)

# Feature Toggles
option(JPEG_WITH_TURBOJPEG "Include the TurboJPEG API library and tools" ON)
option(JPEG_WITH_SIMD "Include SIMD extensions if available" ON)
option(JPEG_REQUIRE_SIMD "Fatal error if SIMD extensions are not available" ON)
option(JPEG_WITH_ARITH_ENC "Include arithmetic encoding support (libjpeg v6b emulation)" ON)
option(JPEG_WITH_ARITH_DEC "Include arithmetic decoding support (libjpeg v6b emulation)" ON)

# Build Components
option(JPEG_WITH_JAVA "Build Java wrapper for TurboJPEG (implies JPEG_ENABLE_SHARED=ON)" OFF)
option(JPEG_WITH_TOOLS "Build command-line tools (disabling disables JPEG_WITH_TESTS)" OFF)
option(JPEG_WITH_TESTS "Enable regression tests and test programs" OFF)
option(JPEG_WITH_FUZZ "Build fuzz targets" OFF)

# Performance Options
option(JPEG_FORCE_INLINE "Force function inlining for better performance" ON)