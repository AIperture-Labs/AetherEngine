# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html
#
# FindUv
# ------
# Find the uv package manager
#
# This will define the following variables:
#   Uv_EXECUTABLE   - Path to the uv executable
#   Uv_VERSION      - Version of uv
#
# And the following imported targets:
#   Uv::uv          - The uv executable

cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW)

# Find the uv executable
find_program(Uv_EXECUTABLE
    NAMES uv uv.exe
    PATHS
        "${AETHER_ENGINE_RUNTIMES_DIR}/uv"
        "$ENV{UV_INSTALL_DIR}"
    DOC "uv package manager executable"
)

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
endif()

mark_as_advanced(Uv_EXECUTABLE Uv_VERSION)

cmake_policy(POP)
