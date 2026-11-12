# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0

include(AetherModule)
include(CompilerWarnings)
include(Coverage)

# aether_add_engine_module(<module> SOURCES <source>...)
#
# Declare the engine module <module> of sources/<module>/: the target aether_<module>, its alias
# AetherEngine::<module> and its export macro AETHER_<MODULE>_API in <aether/<module>/export.hpp>. On top of
# aether_add_module(), it adds what only the engine's own code gets: warnings as errors and coverage.
function(aether_add_engine_module module)
    set(target aether_${module})
    aether_add_module(${target} INCLUDE_PREFIX aether/${module} ${ARGN})
    add_library(AetherEngine::${module} ALIAS ${target})
    enable_warnings(${target})
    enable_coverage(${target})
endfunction()
