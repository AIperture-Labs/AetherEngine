# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# ==============================================================================================================
# External Dependencies
# ==============================================================================================================

# GLM
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