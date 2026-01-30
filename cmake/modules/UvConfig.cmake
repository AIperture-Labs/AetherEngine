# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html
#
# UvConfig
# --------
# Configuration file for uv package manager

cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW)

# Set default version if not specified
if(NOT DEFINED AETHER_ENGINE_UV_VERSION)
    set(AETHER_ENGINE_UV_VERSION "0.9.27" CACHE STRING "uv version used by the project.")
endif()

# Set cache directory
if(NOT DEFINED AETHER_ENGINE_UV_CACHE_DIR)
    if(DEFINED AETHER_ENGINE_CACHE_DIR)
        set(AETHER_ENGINE_UV_CACHE_DIR "${AETHER_ENGINE_CACHE_DIR}/uv")
    else()
        set(AETHER_ENGINE_UV_CACHE_DIR "${CMAKE_BINARY_DIR}/.cache/uv")
    endif()
endif()

# Set runtimes directory
if(NOT DEFINED AETHER_ENGINE_UV_RUNTIMES_DIR)
    if(DEFINED AETHER_ENGINE_RUNTIMES_DIR)
        set(AETHER_ENGINE_UV_RUNTIMES_DIR "${AETHER_ENGINE_RUNTIMES_DIR}/uv")
    else()
        set(AETHER_ENGINE_UV_RUNTIMES_DIR "${CMAKE_BINARY_DIR}/runtimes/uv")
    endif()
endif()

# Find the uv executable
find_program(Uv_EXECUTABLE
    NAMES uv uv.exe
    PATHS
        "${AETHER_ENGINE_UV_RUNTIMES_DIR}"
        "${AETHER_ENGINE_RUNTIMES_DIR}/uv"
        "$ENV{UV_INSTALL_DIR}"
    DOC "uv package manager executable"
    NO_DEFAULT_PATH
)

# Fallback to system paths if not found
if(NOT Uv_EXECUTABLE)
    find_program(Uv_EXECUTABLE
        NAMES uv uv.exe
        DOC "uv package manager executable"
    )
endif()

# Get version if found
if(Uv_EXECUTABLE)
    execute_process(
        COMMAND "${Uv_EXECUTABLE}" --version
        OUTPUT_VARIABLE _uv_version_output
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Parse version from output like "uv 0.9.27"
    if(_uv_version_output MATCHES "uv ([0-9]+\\.[0-9]+\\.[0-9]+)")
        set(Uv_VERSION "${CMAKE_MATCH_1}")
    endif()
endif()

# Set up UV command with config if available
if(Uv_EXECUTABLE)
    set(AETHER_ENGINE_UV_EXE "${Uv_EXECUTABLE}")
    
    # Configure config file if template exists
    if(DEFINED AETHER_ENGINE_CONFIGS_DIR)
        set(_uv_config_template "${AETHER_ENGINE_CONFIGS_DIR}/runtimes/uv/uv.toml.in")
        set(_uv_config_path "${AETHER_ENGINE_CONFIGS_DIR}/runtimes/uv/uv.toml")
        
        if(EXISTS "${_uv_config_template}")
            message(STATUS "[uv] Configuring config file: ${_uv_config_path}")
            configure_file("${_uv_config_template}" "${_uv_config_path}" @ONLY)
            set(AETHER_ENGINE_UV_CONFIG_FILE "${_uv_config_path}")
        elseif(EXISTS "${_uv_config_path}")
            set(AETHER_ENGINE_UV_CONFIG_FILE "${_uv_config_path}")
        endif()
    endif()
    
    # Build UV command
    set(AETHER_ENGINE_UV_COMMAND "${Uv_EXECUTABLE}")
    if(DEFINED AETHER_ENGINE_UV_CONFIG_FILE)
        string(APPEND AETHER_ENGINE_UV_COMMAND " --config-file ${AETHER_ENGINE_UV_CONFIG_FILE}")
    endif()
    if(DEFINED AETHER_ENGINE_PROJECT_DIR)
        string(APPEND AETHER_ENGINE_UV_COMMAND " --directory ${AETHER_ENGINE_PROJECT_DIR}")
    endif()
endif()

# Handle standard arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Uv
    REQUIRED_VARS Uv_EXECUTABLE
    VERSION_VAR Uv_VERSION
)

# Create imported target
if(Uv_FOUND AND NOT TARGET Uv::uv)
    add_executable(Uv::uv IMPORTED)
    set_target_properties(Uv::uv PROPERTIES
        IMPORTED_LOCATION "${Uv_EXECUTABLE}"
    )
    
    # Set version property if available
    if(DEFINED Uv_VERSION)
        set_target_properties(Uv::uv PROPERTIES
            VERSION "${Uv_VERSION}"
        )
    endif()
endif()

mark_as_advanced(Uv_EXECUTABLE Uv_VERSION)

cmake_policy(POP)

# Include helper functions at the end to ensure variables are set
if(Uv_FOUND)
    include("${CMAKE_CURRENT_LIST_DIR}/UvHelpers.cmake" OPTIONAL)
endif()
