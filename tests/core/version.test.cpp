// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN

#include <doctest/doctest.h>

#include <aether/core/version.hpp>
#include <string>
#include <string_view>

TEST_CASE("the version constants agree with their rendered form")
{
    const std::string rendered = std::to_string(aether::core::kVersionMajor) + "." +
                                 std::to_string(aether::core::kVersionMinor) + "." +
                                 std::to_string(aether::core::kVersionPatch);

    CHECK(rendered == aether::core::kVersionString);
}

TEST_CASE("the linked library reports the version its headers declare")
{
    // Fails when the test links against a build of the engine older than these headers, which is
    // the whole reason versionString() is compiled into the library instead of inlined here.
    CHECK(std::string_view{aether::core::versionString()} == std::string_view{aether::core::kVersionString});
}
