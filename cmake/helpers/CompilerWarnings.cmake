# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://clang.llvm.org/docs/UsersManual.html#options-to-control-error-and-warning-messages
#   - https://clang.llvm.org/docs/UsersManual.html#clang-cl

# enable_warnings(<target>)
#
# Compile <target> with strict warnings, treated as errors. The options are PRIVATE so they never
# reach the consumers of the target.
function(enable_warnings target)
    # clang-cl takes MSVC-style flags, which is why the compiler frontend is tested, not the compiler id.
    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options(${target} PRIVATE /W4 /WX)
    else()
        target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    endif()
endfunction()
