# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0

# test_content: a content module declared like a project outside the engine would, so that CI builds CONTENT in
# both modes until samples/empty (#49) replaces it.
message(STATUS "Configuring test_content")

aether_add_module(
    test_content CONTENT
    SOURCES
        content.cpp
    PRIVATE
        AetherEngine::core
)
