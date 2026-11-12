# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/command/target_compile_definitions.html

# apply_build_profile(<target>)
#
# Define on <target>, and on everything linking it, what AETHER_BUILD_PROFILE compiles in or out. The
# table is in docs/development.md.
function(apply_build_profile target)
    if(AETHER_BUILD_PROFILE STREQUAL "Debug")
        set(
            definitions
            AETHER_PROFILE_DEBUG
            AETHER_LOG_MIN_SEVERITY=Trace
            AETHER_ASSERTIONS=1
            AETHER_VALIDATION=1
        )
    elseif(AETHER_BUILD_PROFILE STREQUAL "Development")
        set(
            definitions
            AETHER_PROFILE_DEVELOPMENT
            AETHER_LOG_MIN_SEVERITY=Info
            AETHER_ASSERTIONS=1
            AETHER_VALIDATION=1
        )
    elseif(AETHER_BUILD_PROFILE STREQUAL "Shipping")
        set(
            definitions
            AETHER_PROFILE_SHIPPING
            AETHER_LOG_MIN_SEVERITY=Warning
            AETHER_ASSERTIONS=0
            AETHER_VALIDATION=0
        )
    else()
        message(FATAL_ERROR "AETHER_BUILD_PROFILE must be Debug, Development or Shipping, not '${AETHER_BUILD_PROFILE}'")
    endif()
    target_compile_definitions(${target} PUBLIC ${definitions})
endfunction()
