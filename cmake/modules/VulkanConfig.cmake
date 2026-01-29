# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# VulkanConfig.cmake - Package Configuration File for Vulkan SDK
# This file provides CMake targets and variables for Vulkan SDK components

# Prevent multiple inclusion
if(TARGET Vulkan::Vulkan)
    return()
endif()

# Find Vulkan SDK via environment variable or registry
if(DEFINED ENV{VULKAN_SDK})
    set(_VULKAN_SDK_PATH "$ENV{VULKAN_SDK}")
elseif(WIN32)
    # Try to find via registry on Windows
    get_filename_component(_VULKAN_SDK_PATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Khronos\\Vulkan;VulkanSDK]" ABSOLUTE)
else()
    message(FATAL_ERROR "VULKAN_SDK environment variable not set. Please source the Vulkan SDK setup script.")
endif()

if(NOT EXISTS "${_VULKAN_SDK_PATH}")
    message(FATAL_ERROR "Vulkan SDK path not found: ${_VULKAN_SDK_PATH}")
endif()

if(NOT Vulkan_FIND_QUIETLY)
    message(STATUS "Vulkan SDK path: ${_VULKAN_SDK_PATH}")
endif()

# Platform-specific library and include paths
if(WIN32)
    set(Vulkan_INCLUDE_DIR "${_VULKAN_SDK_PATH}/Include")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(Vulkan_LIBRARY "${_VULKAN_SDK_PATH}/Lib/vulkan-1.lib")
        set(_VULKAN_LIB_DIR "${_VULKAN_SDK_PATH}/Lib")
        set(_VULKAN_BIN_DIR "${_VULKAN_SDK_PATH}/Bin")
    else()
        set(Vulkan_LIBRARY "${_VULKAN_SDK_PATH}/Lib32/vulkan-1.lib")
        set(_VULKAN_LIB_DIR "${_VULKAN_SDK_PATH}/Lib32")
        set(_VULKAN_BIN_DIR "${_VULKAN_SDK_PATH}/Bin32")
    endif()
elseif(APPLE)
    set(Vulkan_INCLUDE_DIR "${_VULKAN_SDK_PATH}/include")
    set(Vulkan_LIBRARY "${_VULKAN_SDK_PATH}/lib/libvulkan.dylib")
    set(_VULKAN_LIB_DIR "${_VULKAN_SDK_PATH}/lib")
    set(_VULKAN_BIN_DIR "${_VULKAN_SDK_PATH}/bin")
else() # Linux/Unix
    set(Vulkan_INCLUDE_DIR "${_VULKAN_SDK_PATH}/include")
    set(Vulkan_LIBRARY "${_VULKAN_SDK_PATH}/lib/libvulkan.so")
    set(_VULKAN_LIB_DIR "${_VULKAN_SDK_PATH}/lib")
    set(_VULKAN_BIN_DIR "${_VULKAN_SDK_PATH}/bin")
endif()

# Verify required files exist
if(NOT EXISTS "${Vulkan_INCLUDE_DIR}/vulkan/vulkan.h")
    message(FATAL_ERROR "Vulkan headers not found at: ${Vulkan_INCLUDE_DIR}")
endif()

if(NOT EXISTS "${Vulkan_LIBRARY}")
    message(FATAL_ERROR "Vulkan library not found at: ${Vulkan_LIBRARY}")
endif()

# Extract version from vulkan_core.h
if(EXISTS "${Vulkan_INCLUDE_DIR}/vulkan/vulkan_core.h")
    file(STRINGS "${Vulkan_INCLUDE_DIR}/vulkan/vulkan_core.h" _vulkan_version_lines
        REGEX "^#define[ \t]+VK_HEADER_VERSION(_COMPLETE)?[ \t]+")
    
    foreach(_line ${_vulkan_version_lines})
        if(_line MATCHES "VK_HEADER_VERSION_COMPLETE[ \t]+VK_MAKE_API_VERSION\\([^,]+,[ \t]*([0-9]+),[ \t]*([0-9]+),[ \t]*VK_HEADER_VERSION\\)")
            set(Vulkan_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(Vulkan_VERSION_MINOR "${CMAKE_MATCH_2}")
        elseif(_line MATCHES "VK_HEADER_VERSION[ \t]+([0-9]+)")
            set(Vulkan_VERSION_PATCH "${CMAKE_MATCH_1}")
        endif()
    endforeach()
    
    if(DEFINED Vulkan_VERSION_MAJOR)
        set(Vulkan_VERSION "${Vulkan_VERSION_MAJOR}.${Vulkan_VERSION_MINOR}.${Vulkan_VERSION_PATCH}")
    endif()
endif()

# Create main Vulkan::Vulkan imported target
add_library(Vulkan::Vulkan UNKNOWN IMPORTED)
set_target_properties(Vulkan::Vulkan PROPERTIES
    IMPORTED_LOCATION "${Vulkan_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${Vulkan_INCLUDE_DIR}"
)

# Create Vulkan::Headers target (header-only)
add_library(Vulkan::Headers INTERFACE IMPORTED)
set_target_properties(Vulkan::Headers PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Vulkan_INCLUDE_DIR}"
)

# Create Vulkan::cppm target for C++20 module support
# Check if ENABLE_CPP20_MODULE option is set and vulkan.cppm exists
if(ENABLE_CPP20_MODULE AND EXISTS "${Vulkan_INCLUDE_DIR}/vulkan/vulkan.cppm")
    add_library(VulkanCppModule)
    add_library(Vulkan::cppm ALIAS VulkanCppModule)
    
    target_compile_definitions(VulkanCppModule
        PUBLIC 
            VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1 
            VULKAN_HPP_NO_STRUCT_CONSTRUCTORS=1
    )
    
    target_include_directories(VulkanCppModule
        PUBLIC "${Vulkan_INCLUDE_DIR}"
    )
    
    target_link_libraries(VulkanCppModule
        PUBLIC Vulkan::Vulkan
    )
    
    set_target_properties(VulkanCppModule PROPERTIES
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED ON
    )
    
    # Add MSVC-specific compiler options for proper C++ module support
    if(MSVC)
        target_compile_options(VulkanCppModule PRIVATE
            /std:c++latest
            /permissive-
            /Zc:__cplusplus
            /EHsc
            /Zc:preprocessor
            /translateInclude
        )
    endif()
    
    target_sources(VulkanCppModule
        PUBLIC
            FILE_SET cxx_modules TYPE CXX_MODULES
            BASE_DIRS "${Vulkan_INCLUDE_DIR}"
            FILES "${Vulkan_INCLUDE_DIR}/vulkan/vulkan.cppm"
    )
    
    set(Vulkan_cppm_FOUND TRUE)
    if(NOT Vulkan_FIND_QUIETLY)
        message(STATUS "Vulkan C++20 module support enabled")
    endif()
else()
    # Create a dummy interface library when C++20 module is disabled or unavailable
    add_library(VulkanCppModule INTERFACE)
    add_library(Vulkan::cppm ALIAS VulkanCppModule)
    target_link_libraries(VulkanCppModule INTERFACE Vulkan::Vulkan)
    target_compile_definitions(VulkanCppModule
        INTERFACE VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1 VULKAN_HPP_NO_STRUCT_CONSTRUCTORS=1
    )
    set(Vulkan_cppm_FOUND FALSE)
endif()

# Find and create targets for optional components
# glslc - SPIR-V compiler
find_program(Vulkan_GLSLC_EXECUTABLE
    NAMES glslc
    HINTS "${_VULKAN_BIN_DIR}"
    DOC "Vulkan GLSL to SPIR-V compiler"
)

if(Vulkan_GLSLC_EXECUTABLE)
    add_executable(Vulkan::glslc IMPORTED)
    set_property(TARGET Vulkan::glslc PROPERTY IMPORTED_LOCATION "${Vulkan_GLSLC_EXECUTABLE}")
    set(Vulkan_glslc_FOUND TRUE)
    if(NOT Vulkan_FIND_QUIETLY)
        message(STATUS "Found Vulkan component: glslc")
    endif()
else()
    set(Vulkan_glslc_FOUND FALSE)
endif()

# glslangValidator - Shader validator
find_program(Vulkan_GLSLANG_VALIDATOR_EXECUTABLE
    NAMES glslangValidator
    HINTS "${_VULKAN_BIN_DIR}"
    DOC "Vulkan GLSL and HLSL validator"
)

if(Vulkan_GLSLANG_VALIDATOR_EXECUTABLE)
    add_executable(Vulkan::glslangValidator IMPORTED)
    set_property(TARGET Vulkan::glslangValidator PROPERTY IMPORTED_LOCATION "${Vulkan_GLSLANG_VALIDATOR_EXECUTABLE}")
    set(Vulkan_glslangValidator_FOUND TRUE)
    if(NOT Vulkan_FIND_QUIETLY)
        message(STATUS "Found Vulkan component: glslangValidator")
    endif()
else()
    set(Vulkan_glslangValidator_FOUND FALSE)
endif()

# dxc - DirectX Shader Compiler
find_program(Vulkan_DXC_EXECUTABLE
    NAMES dxc
    HINTS "${_VULKAN_BIN_DIR}"
    DOC "DirectX Shader Compiler"
)

if(Vulkan_DXC_EXECUTABLE)
    add_executable(Vulkan::dxc_exe IMPORTED)
    set_property(TARGET Vulkan::dxc_exe PROPERTY IMPORTED_LOCATION "${Vulkan_DXC_EXECUTABLE}")
    set(Vulkan_dxc_exe_FOUND TRUE)
    if(NOT Vulkan_FIND_QUIETLY)
        message(STATUS "Found Vulkan component: dxc")
    endif()
else()
    set(Vulkan_dxc_exe_FOUND FALSE)
endif()

# slangc - Slang Shader Compiler
find_program(Vulkan_SLANGC_EXECUTABLE
    NAMES slangc
    HINTS "${_VULKAN_BIN_DIR}"
    DOC "Slang Shader Compiler"
)

if(Vulkan_SLANGC_EXECUTABLE)
    add_executable(Vulkan::slangc IMPORTED)
    set_property(TARGET Vulkan::slangc PROPERTY IMPORTED_LOCATION "${Vulkan_SLANGC_EXECUTABLE}")
    set(Vulkan_slangc_FOUND TRUE)
    if(NOT Vulkan_FIND_QUIETLY)
        message(STATUS "Found Vulkan component: slangc")
    endif()
else()
    set(Vulkan_slangc_FOUND FALSE)
endif()

# Validation layers (optional)
if(WIN32)
    find_library(Vulkan_Layer_VALIDATION
        NAMES VkLayer_khronos_validation
        HINTS "${_VULKAN_LIB_DIR}"
    )
    if(Vulkan_Layer_VALIDATION AND NOT Vulkan_FIND_QUIETLY)
        message(STATUS "Found Vulkan validation layer")
    endif()
endif()

# Set standard find_package variables
set(Vulkan_FOUND TRUE)
set(Vulkan_INCLUDE_DIRS "${Vulkan_INCLUDE_DIR}")
set(Vulkan_LIBRARIES "${Vulkan_LIBRARY}")

# Provide component-specific found variables
foreach(_component ${Vulkan_FIND_COMPONENTS})
    if(NOT Vulkan_${_component}_FOUND)
        if(Vulkan_FIND_REQUIRED_${_component})
            message(FATAL_ERROR "Vulkan component ${_component} not found")
        endif()
    endif()
endforeach()

# Cleanup internal variables
unset(_VULKAN_SDK_PATH)
unset(_VULKAN_LIB_DIR)
unset(_VULKAN_BIN_DIR)
unset(_vulkan_version_lines)

# Status message
if(NOT Vulkan_FIND_QUIETLY)
    message(STATUS "Found Vulkan: ${Vulkan_LIBRARY} (version ${Vulkan_VERSION})")
endif()

# Include helper functions for shader compilation
include("${CMAKE_CURRENT_LIST_DIR}/VulkanShaders.cmake")
