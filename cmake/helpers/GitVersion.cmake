# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/module/FindGit.html
#   - https://git-scm.com/docs/git-describe

# git_version(<out_var> FALLBACK <X.Y.Z>)
#
# Set <out_var> to the latest vX.Y.Z tag reachable from HEAD, without the leading v, or to the fallback when
# there is no such tag or no git. Read at configure time only: reconfigure after tagging.
function(git_version out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "FALLBACK" "")
    set(version "${arg_FALLBACK}")

    find_package(Git QUIET)
    if(Git_FOUND)
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" describe --tags --match "v[0-9]*" --exclude "v*-*" --abbrev=0
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            OUTPUT_VARIABLE tag
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
            RESULT_VARIABLE result
        )
        # Pre-release tags (v1.2.0-rc1) are excluded above: project(VERSION) takes a plain X.Y.Z.
        if(result EQUAL 0 AND tag MATCHES "^v([0-9]+\\.[0-9]+\\.[0-9]+)$")
            set(version "${CMAKE_MATCH_1}")
        endif()
    endif()

    set(${out_var} "${version}" PARENT_SCOPE)
endfunction()
