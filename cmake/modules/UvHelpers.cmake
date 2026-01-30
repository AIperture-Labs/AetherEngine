# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html
#
# UvHelpers
# ---------
# Helper functions for working with uv package manager

#[=======================================================================[.rst:
uv_python_install
-----------------

Installs a specific Python version using the uv package manager.

.. command:: uv_python_install

  .. code-block:: cmake

    uv_python_install(
      INSTALL_DIR <directory>
      CONFIG_FILE <path>
      VERSION <version>
    )

  ``INSTALL_DIR``
    Required. The directory where Python will be installed.

  ``CONFIG_FILE``
    Required. Path to the uv configuration file.

  ``VERSION``
    Required. The Python version to install (e.g., "3.11", "3.12.1").

Example:

.. code-block:: cmake

  uv_python_install(
    INSTALL_DIR "${CMAKE_BINARY_DIR}/python"
    CONFIG_FILE "${PROJECT_SOURCE_DIR}/.uv/config.toml"
    VERSION "3.11"
  )

#]=======================================================================]
function(uv_python_install)
    cmake_parse_arguments(
        UV_PYTHON
        ""
        "INSTALL_DIR;CONFIG_FILE;VERSION"
        ""
        ${ARGN}
    )
    if(NOT UV_PYTHON_INSTALL_DIR)
        message(FATAL_ERROR "[uv-python-install] INSTALL_DIR parameter is required")
    endif()
    if(NOT UV_PYTHON_CONFIG_FILE)
        message(FATAL_ERROR "[uv-python-install] CONFIG_FILE parameter is required")
    endif()
    if(NOT UV_PYTHON_VERSION)
        message(FATAL_ERROR "[uv-python-install] VERSION parameter is required")
    endif()

    message(STATUS "[uv_python_install] Installing Python ${UV_PYTHON_VERSION} at ${UV_PYTHON_INSTALL_DIR} using config ${UV_PYTHON_CONFIG_FILE}")

    execute_process(
        COMMAND
        "${Uv_EXECUTABLE}"
        "--config-file" "${UV_PYTHON_CONFIG_FILE}"
        "python" "install" "-i" "${UV_PYTHON_INSTALL_DIR}" "${UV_PYTHON_VERSION}"
        RESULT_VARIABLE __result
        OUTPUT_VARIABLE __output
        ERROR_VARIABLE __error
        OUTPUT_QUIET
    )
    if(NOT __result EQUAL 0)
        message(FATAL_ERROR "[uv_python_install] Failed with code ${__result}\nOutput: ${__output}\nError: ${__error}")
    endif()
    message(STATUS "[uv_python_install] Python ${UV_PYTHON_VERSION} installed at ${UV_PYTHON_INSTALL_DIR}")
    file(GLOB _python_version_dir "${UV_PYTHON_INSTALL_DIR}/*${UV_PYTHON_VERSION}*")
    find_program(Uv_Python_EXECUTABLE
        NAMES python python.exe
        PATHS "${_python_version_dir}"
        DOC "project python executable."
    )
    set(Uv_Python_EXECUTABLE "${Uv_Python_EXECUTABLE}" PARENT_SCOPE)
endfunction()
