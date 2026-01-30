# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Compiler Warnings Configuration
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# ==============================================================================
# enable_warnings(target)
# ==============================================================================
# Apply strict compiler warnings to a specific target.
#
# This function configures compiler-specific warning flags for a target,
# ensuring consistent warning levels across different compilers (MSVC, GCC, Clang).
# Warnings are treated as errors to enforce code quality standards.
#
# ARGUMENTS:
#   target (required)
#     The CMake target to apply warnings to (e.g., executable or library).
#
# COMPILER-SPECIFIC BEHAVIOR:
#   MSVC (Microsoft Visual C++):
#     - /W4   : Warning level 4 (highest severity)
#     - /WX   : Treat all warnings as errors
#
#   GCC/Clang:
#     - -Wall     : Enable all common warnings
#     - -Wextra   : Enable extra warnings beyond -Wall
#     - -Wpedantic: Enable strict ISO C/C++ compliance warnings
#     - -Werror   : Treat all warnings as errors
#
# USAGE EXAMPLES:
#   enable_warnings(my_executable)
#   enable_warnings(my_library)
#
# NOTES:
#   - Warnings are applied as PRIVATE to avoid propagating to dependent targets
#   - Consider disabling -Werror for external dependencies via target properties
#   - Use add_compile_definitions("DISABLE_PEDANTIC_WARNINGS") to suppress in specific files
#
function(enable_warnings target)
    if(MSVC)
        # MSVC compiler options
        # /W4 : Warning level 4 (highest)
        # /WX : Treat warnings as errors
        target_compile_options(${target} PRIVATE
            /W4
            /WX
        )
    else()
        # GCC/Clang compiler options
        # -Wall : Enable all common warnings
        # -Wextra : Enable extra warnings
        # -Wpedantic : Enable strict ISO compliance warnings
        # -Werror : Treat warnings as errors
        target_compile_options(${target} PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Werror
        )
    endif()
endfunction()
