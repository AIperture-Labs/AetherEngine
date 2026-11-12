# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
#   - https://clangd.llvm.org/installation#compile_commandsjson

# aether_link_compile_commands()
#
# clangd and the other language servers look for compile_commands.json at the repository root, while CMake
# generates it in the build directory: link the former to the latter.
function(aether_link_compile_commands)
    file(
        CREATE_LINK
        "${CMAKE_BINARY_DIR}/compile_commands.json"
        "${CMAKE_SOURCE_DIR}/compile_commands.json"
        SYMBOLIC
        RESULT link_result
    )
    # Creating a symlink can be denied (e.g. on Windows without Developer Mode); that must not stop the
    # configure.
    if(NOT link_result EQUAL 0)
        message(
            WARNING
            "Cannot link compile_commands.json at the root (${link_result}): "
            "language servers will not find it"
        )
    endif()
endfunction()
