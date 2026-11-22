// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <aether/core/version.hpp>
#include <test_content/export.hpp>

extern "C" TEST_CONTENT_API const char *testContentEngineVersion() noexcept
{
    return aether::core::versionString();
}
