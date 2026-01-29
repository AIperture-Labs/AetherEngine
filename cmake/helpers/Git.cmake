# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html


find_package(Git QUIET)
if(NOT GIT_FOUND)
    message(FATAL_ERROR "Git not found. Please install Git and ensure it is in your PATH.")
endif()

#[=======================================================================[.rst:
git_patch
---------

Applies a git patch file to a target directory.

Synopsis
^^^^^^^^

.. code-block:: cmake

  git_patch(
    FILE <patch-file>
    TARGET_DIRECTORY <directory>
  )

Description
^^^^^^^^^^^

This function applies a git patch to a specified directory using ``git apply``.
If the patch fails to apply, a fatal error is raised with the error message.

Arguments
^^^^^^^^^

``FILE <patch-file>``
  The path to the patch file to apply.

``TARGET_DIRECTORY <directory>``
  The directory where the patch should be applied (typically the git repository root).

Example
^^^^^^^

.. code-block:: cmake

  git_patch(
    FILE "${CMAKE_SOURCE_DIR}/patches/yasm-fix.patch"
    TARGET_DIRECTORY "${CMAKE_SOURCE_DIR}/extern/yasm"
  )

#]=======================================================================]
function(git_patch)
    cmake_parse_arguments(
        "GIT_PATCH"
        ""
        "FILE;TARGET_DIRECTORY"
        ""
        ${ARGN}
    )
    execute_process(
        COMMAND git apply ${GIT_PATCH_FILE}
        WORKING_DIRECTORY ${GIT_PATCH_TARGET_DIRECTORY}
        RESULT_VARIABLE RESULT
        ERROR_VARIABLE ERROR
    )

    if(NOT RESULT EQUAL 0)
        message(FATAL_ERROR "Git patch failed: ${ERROR}")
    endif()
endfunction()

#[=======================================================================[.rst:
git_submodules_update
---------------------

Updates and initializes all git submodules recursively.

Synopsis
^^^^^^^^

.. code-block:: cmake

  git_submodules_update()

Description
^^^^^^^^^^^

This function updates and initializes all git submodules in the project recursively
using ``git submodule update --init --recursive``. It only performs the update
if the ``GIT_SUBMODULE`` option is enabled.

If the submodule update fails, a fatal error is raised with the git error code.

Arguments
^^^^^^^^^

This function takes no arguments.

Example
^^^^^^^

.. code-block:: cmake

  # Update all submodules before building
  git_submodules_update()

#]=======================================================================]
function(git_submodules_update)
    if(GIT_SUBMODULE)
        message(STATUS "Submodules update")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_SUBMOD_RESULT)
        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(FATAL_ERROR "git submodule update --init --recursive failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
        endif()
    endif()
endfunction()
