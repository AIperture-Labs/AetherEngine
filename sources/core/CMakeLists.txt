# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs:
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# ==============================================================================================================
# AetherEngine::core
# ==============================================================================================================
# Foundation module: what every other engine module is allowed to depend on. It currently carries
# only the version surface, which doubles as the check that the build, the export macros and the
# test harness are wired together.

message(STATUS "Configuring ${CMAKE_CURRENT_SOURCE_DIR}")

include(GenerateExportHeader)

set(AETHER_CORE_GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/include")

add_library(aether_core
    src/version.cpp
)
add_library(AetherEngine::core ALIAS aether_core)

# Version constants come from project(AetherEngine VERSION ...) in the top-level CMakeLists.txt.
configure_file(
    include/aether/core/version.hpp.in
    "${AETHER_CORE_GENERATED_INCLUDE_DIR}/aether/core/version.hpp"
    @ONLY
)

# Hide symbols by default so the generated export macros, rather than the compiler default,
# decide the public ABI. This is how the library already behaves when built with MSVC.
set_target_properties(aether_core PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

generate_export_header(aether_core
    BASE_NAME AETHER_CORE
    EXPORT_MACRO_NAME AETHER_CORE_API
    EXPORT_FILE_NAME "${AETHER_CORE_GENERATED_INCLUDE_DIR}/aether/core/export.hpp"
)

target_include_directories(aether_core
    PUBLIC
    "$<BUILD_INTERFACE:${AETHER_CORE_GENERATED_INCLUDE_DIR}>"
    $<INSTALL_INTERFACE:include>
)

enable_warnings(aether_core)
