# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Compiler Warnings Configuration
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

# Enable strict compiler warnings for a target
# Usage: enable_warnings(target_name)
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
