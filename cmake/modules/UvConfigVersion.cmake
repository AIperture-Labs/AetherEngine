# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html
#
# UvConfigVersion
# ---------------
# Version compatibility file for uv package manager

set(PACKAGE_VERSION "@AETHER_ENGINE_UV_VERSION@")

# Check whether the requested PACKAGE_FIND_VERSION is compatible
if(PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
    if(PACKAGE_FIND_VERSION STREQUAL PACKAGE_VERSION)
        set(PACKAGE_VERSION_EXACT TRUE)
    endif()
endif()

# If the user requested a specific version, check compatibility
if(DEFINED PACKAGE_FIND_VERSION)
    if(PACKAGE_FIND_VERSION_MAJOR)
        if(NOT PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_FIND_VERSION)
            set(PACKAGE_VERSION_COMPATIBLE FALSE)
        endif()
    endif()
endif()
