# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# ==============================================================================================================
# External Dependencies
# ==============================================================================================================

# Find Vulkan SDK (using custom VulkanConfig.cmake from cmake/modules/)
find_package(Vulkan 1.4.335 CONFIG REQUIRED
    COMPONENTS glslc glslangValidator slangc
)
