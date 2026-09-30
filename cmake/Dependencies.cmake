# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# ==============================================================================================================
# External Dependencies
# ==============================================================================================================

# Ensure all external submodules are initialized and up to date
include(Git)
if(GIT_SUBMODULE_UPDATE)
    git_submodules_update()
endif()

# ==============================================================================================================
# Python Interpreter
# ==============================================================================================================
# Python is only a build-time script host here (yasm generates sources with it), so the system
# interpreter is enough. The vendored UV/Python runtime is a Windows convenience: the release
# asset pinned below is a win-msvc archive, so it stays opt-in behind ENABLE_RUNTIMES.

if(ENABLE_RUNTIMES)
    if(NOT WIN32)
        message(FATAL_ERROR
            "[Dependencies] ENABLE_RUNTIMES downloads a Windows UV release asset and is Windows-only. "
            "Reconfigure with -DENABLE_RUNTIMES=OFF to use the system Python interpreter.")
    endif()

    # Download UV runtime
    find_package(GitHub CONFIG REQUIRED
        COMPONENTS gh)
    gh_release_download(
        OWNER astral-sh REPO uv
        VERSION ${AETHER_ENGINE_UV_VERSION}
        DOWNLOAD_DIR ${AETHER_ENGINE_CACHE_DIR}/uv/releases
        PATTERN "uv-x86_64-pc-windows-msvc.zip"
        EXTRACT_TO ${AETHER_ENGINE_RUNTIMES_DIR}/uv
        FORCE_DOWNLOAD
    )

    # Download and install Python
    find_package(Uv CONFIG REQUIRED)
    uv_python_install(
        CONFIG_FILE ${AETHER_ENGINE_UV_CONFIG_FILE}
        INSTALL_DIR ${AETHER_ENGINE_PYTHON_RUNTIME_DIR}
        VERSION ${AETHER_ENGINE_PYTHON_VERSION}
    )
    set(Python_EXECUTABLE "${Uv_Python_EXECUTABLE}")
else()
    find_package(Python3 ${AETHER_ENGINE_PYTHON_VERSION} MODULE REQUIRED
        COMPONENTS Interpreter)
    set(Python_EXECUTABLE "${Python3_EXECUTABLE}")
endif()

# Keep the legacy all-caps spelling in sync: vendored dependencies still read it.
set(PYTHON_EXECUTABLE "${Python_EXECUTABLE}")
message(STATUS "[Dependencies] Python interpreter: ${Python_EXECUTABLE}")

# ==============================================================================================================
# Assembler
# ==============================================================================================================
# libjpeg-turbo assembles its SIMD kernels with nasm or yasm. Unix package managers ship one, so
# the bundled assembler is built only when the host has none -- in practice, on Windows. Building
# it on a case-sensitive filesystem also trips a bug in the vendored sources, whose
# modules/arch/CMakeLists.txt includes "arch/lc3b/cmakelists.txt" in the wrong case.

find_program(AETHER_ENGINE_ASSEMBLER
    NAMES nasm yasm
    DOC "Assembler used to build the libjpeg-turbo SIMD kernels")

if(AETHER_ENGINE_ASSEMBLER)
    message(STATUS "[Dependencies] Using system assembler: ${AETHER_ENGINE_ASSEMBLER}")
else()
    message(STATUS "[Dependencies] No system assembler found, configuring extern lib: Yasm")
    add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/yasm)
endif()

# ==============================================================================================================
# Libraries
# ==============================================================================================================

# GLM - OpenGL Mathematics library
message(STATUS "[Dependencies] Configuring extern lib: GLM")
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/glm)

# libjpeg-turbo - High-performance JPEG codec
include(LibjpegTurbo)
ConfigureLibjpegTurbo()

# Vulkan - MODULE mode is deliberate. cmake/modules/FindVulkan.cmake is the upstream finder and
# resolves Vulkan from either $VULKAN_SDK or the system packages. The hand-written
# VulkanConfig.cmake beside it only understands an $VULKAN_SDK layout and still carries an
# unsubstituted @Vulkan_VERSION@, so CONFIG mode can never satisfy a version request.
# slangc ships with the LunarG SDK but not with most distro packages, so it stays optional.
find_package(Vulkan 1.4.335 MODULE REQUIRED
    COMPONENTS glslc glslangValidator
    OPTIONAL_COMPONENTS slangc
)
message(STATUS "[Dependencies] Vulkan ${Vulkan_VERSION}: ${Vulkan_LIBRARY}")
if(NOT Vulkan_slangc_FOUND)
    message(STATUS "[Dependencies] slangc not found: Slang shaders cannot be compiled")
endif()

# doctest for unit tests
message(STATUS "[Dependencies] Configuring extern lib: doctest")
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/doctest)
