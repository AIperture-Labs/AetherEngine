# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs:
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html

add_doctest(
    NAME core_tests
    SOURCES version.test.cpp
    LIBS AetherEngine::core
)
