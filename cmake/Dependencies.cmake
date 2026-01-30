# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# ==============================================================================================================
# External Dependencies
# ==============================================================================================================

# Ensure all external submodules are initialized and up to date
include(Git)
if(GIT_SUBMODULES_UPDATE)
    git_submodules_update()
endif()

# Download UV runtime
find_package(GitHub CONFIG REQUIRED
    COMPONENTS gh)
gh_release_download(
    OWNER astral-sh REPO uv
    VERSION 0.9.27
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
set(PYTHON_EXECUTABLE "${Uv_Python_EXECUTABLE}")

# GLM - OpenGL Mathematics library
message(STATUS "Configuring extern lib: GLM")
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/glm)

# YASM (needed for libjpeg-turbo for SIMD optimisations)
message(STATUS "Configuring extern lib: Yasm")
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/yasm)

# libjpeg-turbo - High-performance JPEG codec
include(LibjpegTurbo)
ConfigureLibjpegTurbo()

# Find Vulkan SDK (using custom VulkanConfig.cmake from cmake/modules/)
find_package(Vulkan 1.4.335 CONFIG REQUIRED
    COMPONENTS glslc glslangValidator slangc
)