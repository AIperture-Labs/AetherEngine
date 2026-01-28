# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://cmake.org/cmake/help/v4.1/index.html


set(AETHER_ENGINE_PYTHON_CACHE_DIR "${AETHER_ENGINE_CACHE_DIR}/python")
set(AETHER_ENGINE_PYTHON_VERSION "3.14" CACHE STRING "Python version used by the project.")
set(AETHER_ENGINE_PYTHON_RUNTIME_DIR "${AETHER_ENGINE_RUNTIMES_DIR}/python")


if(NOT EXISTS ${AETHER_ENGINE_UV_EXE})
    message(FATAL_ERROR "[python-install] Uv executable is missing.")
endif()

if(WIN32)
    if(EXISTS ${AETHER_ENGINE_PYTHON_RUNTIME_DIR})
        message(STATUS "[python-install] Python already exists at ${AETHER_ENGINE_PYTHON_RUNTIME_DIR}. Skipping.")

    else()
        # UV Installation
        message(STATUS "[python-install] Installating Python ${AETHER_ENGINE_PYTHON_VERSION}...")
        execute_process(
            COMMAND
            "${AETHER_ENGINE_UV_EXE}"
            "--config-file" "${AETHER_ENGINE_UV_CONFIG}"
            "python" "install" "-i" "${AETHER_ENGINE_PYTHON_RUNTIME_DIR}" "${AETHER_ENGINE_PYTHON_VERSION}"
            RESULT_VARIABLE __result
            OUTPUT_VARIABLE __output
            ERROR_VARIABLE __error
            OUTPUT_QUIET
        )
        message(STATUS "[python-install] Output: ${__output}")
        if(NOT __result EQUAL 0)
            message(FATAL_ERROR "[python-install] Failed with code ${__result}\nOutput: ${__output}\nError: ${__error}")
        endif()
        message(STATUS "[python-install] Finished.")
    endif()

    # UV Project settings
    set(AETHER_ENGINE_PYTHON_EXE "${AETHER_ENGINE_UV_COMMAND} run python")
elseif(UNIX)
    # TODO:
    message(WARNING "MacOS and Linux to implement...")
endif()
