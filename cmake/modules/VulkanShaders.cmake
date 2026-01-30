# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# VulkanShaders.cmake - Helper functions for Vulkan shader compilation
# Requires: Vulkan package to be found first (provides shader compiler targets)

if(NOT TARGET Vulkan::Vulkan)
    message(FATAL_ERROR "VulkanShaders requires Vulkan package. Call find_package(Vulkan) first.")
endif()

#[=======================================================================[.rst:
add_shaders_target
------------------

Compile GLSL shaders to SPIR-V using glslangValidator.

.. code-block:: cmake

  add_shaders_target(<target>
    CHAPTER_NAME <chapter>
    SOURCES <shader1.vert> <shader2.frag>
  )

Creates a custom target that compiles GLSL shaders in the specified chapter directory.

Arguments:
  ``target``
    Name of the custom target to create
  ``CHAPTER_NAME``
    Directory name where shaders are located (relative path)
  ``SOURCES``
    List of shader source files to compile

Output:
  Compiled shaders are placed in ``<CHAPTER_NAME>/shaders/`` directory:
  - ``frag.spv`` - Fragment shader
  - ``vert.spv`` - Vertex shader

#]=======================================================================]
function(add_shaders_target TARGET)
    if(NOT TARGET Vulkan::glslangValidator)
        message(WARNING "[add_shaders_target] glslangValidator not found. Shader compilation disabled for ${TARGET}.")
        return()
    endif()

    cmake_parse_arguments("SHADER" "" "CHAPTER_NAME" "SOURCES" ${ARGN})
    
    if(NOT SHADER_CHAPTER_NAME)
        message(FATAL_ERROR "[add_shaders_target] CHAPTER_NAME is required")
    endif()
    
    if(NOT SHADER_SOURCES)
        message(FATAL_ERROR "[add_shaders_target] SOURCES is required")
    endif()
    
    set(SHADERS_DIR ${SHADER_CHAPTER_NAME}/shaders)
    
    add_custom_command(
        OUTPUT ${SHADERS_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SHADERS_DIR}
    )
    
    add_custom_command(
        OUTPUT ${SHADERS_DIR}/frag.spv ${SHADERS_DIR}/vert.spv
        COMMAND Vulkan::glslangValidator
        ARGS --target-env vulkan1.0 ${SHADER_SOURCES} --quiet
        WORKING_DIRECTORY ${SHADERS_DIR}
        DEPENDS ${SHADERS_DIR} ${SHADER_SOURCES}
        COMMENT "Compiling GLSL Shaders for ${TARGET}"
        VERBATIM
    )
    
    add_custom_target(${TARGET} DEPENDS ${SHADERS_DIR}/frag.spv ${SHADERS_DIR}/vert.spv)
endfunction()


#[=======================================================================[.rst:
add_slang_shader_target
-----------------------

Compile Slang shaders to SPIR-V using slangc.

.. code-block:: cmake

  add_slang_shader_target(<target>
    SOURCES <shader.slang>
  )

Creates a custom target that compiles Slang shaders to SPIR-V.

Arguments:
  ``target``
    Name of the custom target to create
  ``SOURCES``
    List of Slang shader source files to compile

Output:
  Compiled shaders are placed in the build directory matching the source structure:
  - ``slang.spv`` - Compiled SPIR-V binary

#]=======================================================================]
function(add_slang_shader_target TARGET)
    if(NOT TARGET Vulkan::slangc)
        message(WARNING "[add_slang_shader_target] slangc not found. Slang shader compilation disabled for ${TARGET}.")
        return()
    endif()

    cmake_parse_arguments("SHADER" "" "" "SOURCES" ${ARGN})
    
    if(NOT SHADER_SOURCES)
        message(FATAL_ERROR "[add_slang_shader_target] SOURCES is required")
    endif()

    # Use the current source directory relative to the project source
    file(RELATIVE_PATH RELATIVE_SOURCE_DIR
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}
    )

    # Create output directory matching source structure
    set(SHADERS_BINARY_DIR ${CMAKE_BINARY_DIR}/${RELATIVE_SOURCE_DIR})

    set(ENTRY_POINTS -entry vertMain -entry fragMain)
    set(PROFILES -profile spirv_1_4)

    add_custom_command(
        OUTPUT ${SHADERS_BINARY_DIR}/slang.spv
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SHADERS_BINARY_DIR}
        COMMAND Vulkan::slangc ${SHADER_SOURCES} -target spirv ${PROFILES} -emit-spirv-directly -fvk-use-entrypoint-name ${ENTRY_POINTS} -o ${SHADERS_BINARY_DIR}/slang.spv
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS ${SHADER_SOURCES}
        COMMENT "Compiling Slang Shaders to ${RELATIVE_SOURCE_DIR}"
        VERBATIM
    )

    add_custom_target(${TARGET} DEPENDS ${SHADERS_BINARY_DIR}/slang.spv)
endfunction()


#[=======================================================================[.rst:
add_texture_target
------------------

Copy texture assets to the build directory.

.. code-block:: cmake

  add_texture_target(<target>
    SOURCES <texture1.png> <texture2.jpg>
  )

Creates a custom target that copies texture files to the build directory.

Arguments:
  ``target``
    Name of the custom target to create
  ``SOURCES``
    List of texture source files to copy

Output:
  Textures are copied to the build directory matching the source structure.

#]=======================================================================]
function(add_texture_target TARGET)
    cmake_parse_arguments("TEXTURE" "" "" "SOURCES" ${ARGN})
    
    if(NOT TEXTURE_SOURCES)
        message(FATAL_ERROR "[add_texture_target] SOURCES is required")
    endif()

    # Use the current source directory relative to the project source
    file(RELATIVE_PATH RELATIVE_SOURCE_DIR
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}
    )

    # Create output directory matching source structure
    set(TEXTURES_BINARY_DIR ${CMAKE_BINARY_DIR}/${RELATIVE_SOURCE_DIR})

    set(TEXTURE_BINARIES "")

    foreach(TEXTURE_SOURCE ${TEXTURE_SOURCES})
        get_filename_component(TEXTURE_FILENAME "${TEXTURE_SOURCE}" NAME)
        set(TEXTURE_BINARY "${TEXTURES_BINARY_DIR}/${TEXTURE_FILENAME}")
        list(APPEND TEXTURE_BINARIES "${TEXTURE_BINARY}")
        
        add_custom_command(
            OUTPUT ${TEXTURE_BINARY}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${TEXTURES_BINARY_DIR}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${TEXTURE_SOURCE}" "${TEXTURE_BINARY}"
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            DEPENDS ${TEXTURE_SOURCE}
            COMMENT "Copying texture ${TEXTURE_FILENAME} to ${RELATIVE_SOURCE_DIR}"
            VERBATIM
        )
    endforeach()
    
    add_custom_target(${TARGET} ALL DEPENDS ${TEXTURE_BINARIES})
endfunction()
