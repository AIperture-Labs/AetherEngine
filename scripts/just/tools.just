# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://just.systems/man/en/

# Show versions of core dev tools: git, code, clang
get-tools-version:
    git --version
    code --version
    cmake --version
    clang --version
    clangd --version
    ninja --version