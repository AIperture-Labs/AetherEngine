# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# VulkanConfigVersion.cmake - Version checking for Vulkan package

set(PACKAGE_VERSION "@Vulkan_VERSION@")

# Extract version from vulkan_core.h if available
if(DEFINED ENV{VULKAN_SDK})
    set(_VULKAN_SDK "$ENV{VULKAN_SDK}")
    if(WIN32)
        set(_VULKAN_INCLUDE "${_VULKAN_SDK}/Include")
    else()
        set(_VULKAN_INCLUDE "${_VULKAN_SDK}/include")
    endif()
    
    if(EXISTS "${_VULKAN_INCLUDE}/vulkan/vulkan_core.h")
        file(STRINGS "${_VULKAN_INCLUDE}/vulkan/vulkan_core.h" _version_lines
            REGEX "^#define[ \t]+VK_HEADER_VERSION(_COMPLETE)?[ \t]+")
        
        foreach(_line ${_version_lines})
            if(_line MATCHES "VK_HEADER_VERSION_COMPLETE[ \t]+VK_MAKE_API_VERSION\\([^,]+,[ \t]*([0-9]+),[ \t]*([0-9]+),[ \t]*VK_HEADER_VERSION\\)")
                set(_VERSION_MAJOR "${CMAKE_MATCH_1}")
                set(_VERSION_MINOR "${CMAKE_MATCH_2}")
            elseif(_line MATCHES "VK_HEADER_VERSION[ \t]+([0-9]+)")
                set(_VERSION_PATCH "${CMAKE_MATCH_1}")
            endif()
        endforeach()
        
        if(DEFINED _VERSION_MAJOR)
            set(PACKAGE_VERSION "${_VERSION_MAJOR}.${_VERSION_MINOR}.${_VERSION_PATCH}")
        endif()
    endif()
    
    unset(_VULKAN_SDK)
    unset(_VULKAN_INCLUDE)
    unset(_version_lines)
    unset(_VERSION_MAJOR)
    unset(_VERSION_MINOR)
    unset(_VERSION_PATCH)
endif()

# Perform version checking
if(PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
    if(PACKAGE_FIND_VERSION STREQUAL PACKAGE_VERSION)
        set(PACKAGE_VERSION_EXACT TRUE)
    endif()
endif()

# Vulkan uses semantic versioning, so we check compatibility
if(PACKAGE_FIND_VERSION_MAJOR STREQUAL PACKAGE_VERSION_MAJOR)
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
else()
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
endif()
