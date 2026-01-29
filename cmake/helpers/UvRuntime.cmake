# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html


set(AETHER_ENGINE_UV_CACHE_DIR "${AETHER_ENGINE_CACHE_DIR}/uv")
set(AETHER_ENGINE_UV_VERSION "0.9.27" CACHE STRING "uv version used by the project.")


if(WIN32)
    set(AETHER_ENGINE_UV_EXE "${AETHER_ENGINE_RUNTIMES_DIR}/uv/uv.exe")
    if(EXISTS ${AETHER_ENGINE_UV_EXE})
        message(STATUS "[uv-install] uv already exists at ${AETHER_ENGINE_UV_EXE}. Skipping.")
    else()
        # UV Installation
        message(STATUS "[uv-install] Downloading and running uv ${AETHER_ENGINE_UV_VERSION} installer...")
        file(
            DOWNLOAD https://github.com/astral-sh/uv/releases/download/${AETHER_ENGINE_UV_VERSION}/uv-installer.ps1
            ${AETHER_ENGINE_UV_CACHE_DIR}/uv-installer.ps1
        )
        execute_process(
            COMMAND "pwsh" "-c" "$env:UV_INSTALL_DIR = '${AETHER_ENGINE_RUNTIMES_DIR}/uv'; & '${AETHER_ENGINE_UV_CACHE_DIR}/uv-installer.ps1'"
            RESULT_VARIABLE __result
            OUTPUT_VARIABLE __output
            ERROR_VARIABLE __error
            OUTPUT_QUIET
        )
        if(NOT __result EQUAL 0)
            message(FATAL_ERROR "[uv-install] Failed with code ${__result}\nOutput: ${__output}\nError: ${__error}")
        endif()
        message(STATUS "[uv-install] Finished.")
    endif()

    # UV Project settings
    set(AETHER_ENGINE_UV_CONFIG "${AETHER_ENGINE_CONFIGS_DIR}/runtimes/uv/uv.toml")
    message(STATUS "Config file : ${AETHER_ENGINE_UV_CONFIG}")
    configure_file("${AETHER_ENGINE_UV_CONFIG}.in" "${AETHER_ENGINE_UV_CONFIG}")
    set(AETHER_ENGINE_UV_COMMAND "${AETHER_ENGINE_UV_EXE} --config-file ${AETHER_ENGINE_UV_CONFIG} --directory ${AETHER_ENGINE_PROJECT_DIR}")
elseif(UNIX)
    # TODO: do the same for UN*X 
    # https://github.com/astral-sh/uv/releases
    message(WARNING "MacOS and Linux to implement...")
endif()
