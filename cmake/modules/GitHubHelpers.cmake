# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html


function(gh_release_download)
    # Use only GitHubCli_EXECUTABLE
    if(NOT GitHubCli_EXECUTABLE)
        message(FATAL_ERROR "GitHub CLI executable is not installed. Please install it and ensure it is available in your PATH.")
    endif()
    # Use GitHubCli_EXECUTABLE directly in execute_process

    # Parse arguments for GitHub release download
    cmake_parse_arguments(RELEASE "" "OWNER;REPO;VERSION;DOWNLOAD_DIR;EXTRACT_TO;FORCE_DOWNLOAD" "PATTERN" ${ARGN})

    # Check for required arguments
    if(NOT RELEASE_OWNER)
        message(FATAL_ERROR "[gh_release_download] OWNER argument is required.")
    endif()
    if(NOT RELEASE_REPO)
        message(FATAL_ERROR "[gh_release_download] REPO argument is required.")
    endif()
    if(NOT RELEASE_VERSION)
        message(FATAL_ERROR "[gh_release_download] VERSION argument is required.")
    endif()
    if(NOT RELEASE_DOWNLOAD_DIR)
        message(FATAL_ERROR "[gh_release_download] DOWNLOAD_DIR argument is required.")
    endif()

    # Manage argument if download is forced (from parsed arguments)
    set(_force_download "--skip-existing")
    if(DEFINED RELEASE_FORCE_DOWNLOAD)
        set(_force_download "--clobber")
    endif()

    # Build pattern arguments for zero, one, or more patterns
    set(_pattern_args)
    if(RELEASE_PATTERN)
        foreach(_pat IN LISTS RELEASE_PATTERN)
            list(APPEND _pattern_args -p "${_pat}")
        endforeach()
    endif()

    # Ensure the target download directory exists
    file(MAKE_DIRECTORY "${RELEASE_DOWNLOAD_DIR}")

    # Download a release asset from GitHub using the GitHub CLI
    message(STATUS "[gh_release_download] Downloading release assets for ${RELEASE_OWNER}/${RELEASE_REPO} version ${RELEASE_VERSION}...")
    execute_process(
        COMMAND "${GitHubCli_EXECUTABLE}" release download "${RELEASE_VERSION}" -R "${RELEASE_OWNER}/${RELEASE_REPO}" ${_pattern_args} ${_force_download}
        WORKING_DIRECTORY "${RELEASE_DOWNLOAD_DIR}"
        RESULT_VARIABLE __result
        OUTPUT_VARIABLE __output
        ERROR_VARIABLE __error
        OUTPUT_QUIET
    )
    message(STATUS "[gh_release_download] Download finished for ${RELEASE_OWNER}/${RELEASE_REPO} version ${RELEASE_VERSION}.")

    if(NOT __result EQUAL 0)
        message(FATAL_ERROR "[gh_release_download] Failed with code ${__result}\nOutput: ${__output}\nError: ${__error}")
    endif()

    # Optionally extract if EXTRACT_TO is provided and a single archive is found
    if(DEFINED RELEASE_EXTRACT_TO AND NOT "${RELEASE_EXTRACT_TO}" STREQUAL "")
        file(GLOB _archives "${RELEASE_DOWNLOAD_DIR}/*.zip" "${RELEASE_DOWNLOAD_DIR}/*.tar.gz" "${RELEASE_DOWNLOAD_DIR}/*.tgz" "${RELEASE_DOWNLOAD_DIR}/*.tar.xz" "${RELEASE_DOWNLOAD_DIR}/*.tar.bz2")
        if(_archives)
            list(GET _archives 0 _archive_file)
            message(STATUS "[gh_release_download] Extracting ${_archive_file} to ${RELEASE_EXTRACT_TO}...")
            file(MAKE_DIRECTORY "${RELEASE_EXTRACT_TO}")
            file(ARCHIVE_EXTRACT INPUT "${_archive_file}" DESTINATION "${RELEASE_EXTRACT_TO}" VERBOSE)
            message(STATUS "[gh_release_download] Extraction finished.")
        else()
            message(WARNING "[gh_release_download] No archive found to extract in ${RELEASE_DOWNLOAD_DIR}.")
        endif()
    endif()
endfunction()
