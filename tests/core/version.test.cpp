// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <doctest/doctest.h>

#include <aether/core/version.hpp>
#include <string>

namespace aether::core {

TEST_CASE("the version string is built from the version components")
{
    const std::string expected =
        std::to_string(kVersionMajor) + "." + std::to_string(kVersionMinor) + "." + std::to_string(kVersionPatch);
    CHECK(expected == versionString());
}

}  // namespace aether::core
