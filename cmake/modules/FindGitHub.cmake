# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html
#
# FindGitHub
# ----------
# Find the GitHub CLI and related tools
#
# This will define the following variables:
#   GitHubCli_EXECUTABLE   - Path to the gh executable
#   GitHubCli_VERSION      - Version of GitHub CLI
#
# And the following imported targets:
#   GitHub::gh          - The GitHub CLI executable

cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW)

# Find the gh executable
find_program(GitHubCli_EXECUTABLE
    NAMES gh gh.exe
    DOC "GitHub CLI executable"
)

# Get version if found
if(GitHubCli_EXECUTABLE)
    execute_process(
        COMMAND "${GitHubCli_EXECUTABLE}" --version
        OUTPUT_VARIABLE _gh_version_output
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Parse version from output like "gh version 2.40.1 (2024-01-01)"
    if(_gh_version_output MATCHES "gh version ([0-9]+\\.[0-9]+\\.[0-9]+)")
        set(GitHubCli_VERSION "${CMAKE_MATCH_1}")
    endif()
endif()

# Handle components
set(_GitHub_REQUIRED_VARS)

# gh component (GitHub CLI)
if("gh" IN_LIST GitHub_FIND_COMPONENTS OR NOT GitHub_FIND_COMPONENTS)
    list(APPEND _GitHub_REQUIRED_VARS GitHubCli_EXECUTABLE)
    if(GitHubCli_EXECUTABLE)
        set(GitHub_gh_FOUND TRUE)
    else()
        set(GitHub_gh_FOUND FALSE)
    endif()
endif()

# Handle standard arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GitHub
    REQUIRED_VARS ${_GitHub_REQUIRED_VARS}
    VERSION_VAR GitHubCli_VERSION
    HANDLE_COMPONENTS
)

# Create imported targets for found components
if(GitHub_gh_FOUND AND NOT TARGET GitHub::gh)
    add_executable(GitHub::gh IMPORTED)
    set_target_properties(GitHub::gh PROPERTIES
        IMPORTED_LOCATION "${GitHubCli_EXECUTABLE}"
    )
endif()

mark_as_advanced(GitHubCli_EXECUTABLE GitHubCli_VERSION)

cmake_policy(POP)

# Include helper functions at the end to ensure variables are set
if(GitHub_FOUND)
    include("${CMAKE_CURRENT_LIST_DIR}/GitHubHelpers.cmake")
endif()
