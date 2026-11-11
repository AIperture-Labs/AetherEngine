// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <doctest/doctest.h>

#include <aether/core/assert.hpp>
#include <aether/core/logger.hpp>
#include <cstdlib>
#include <filesystem>
#include <format>
#include <fstream>
#include <sstream>
#include <string>

namespace aether::core {

namespace {

struct Run
{
    int         status;
    std::string output;
};

// doctest has no death tests: the helper executable fails in a child process, whose stderr (the console sink)
// goes to a file. std::system and the 2> redirection are the same on Linux and Windows.
Run runHelper(const std::string &mode)
{
    const auto output  = std::filesystem::temp_directory_path() / ("aether_assert_" + mode + ".log");
    const auto command = std::format(R"("{}" {} 2> "{}")", AETHER_ASSERT_HELPER, mode, output.generic_string());
#ifdef _WIN32
    // cmd /c strips the outer quotes of the command.
    const int status = std::system(std::format(R"("{}")", command).c_str());
#else
    // The command is built from the helper path, a constant of the build, and a literal mode.
    // NOLINTNEXTLINE(bugprone-command-processor)
    const int status = std::system(command.c_str());
#endif
    std::ifstream     file(output);
    std::stringstream content;
    content << file.rdbuf();
    return {.status = status, .output = content.str()};
}

}  // namespace

TEST_CASE("the profile definitions agree with the profile")
{
    switch (kBuildProfile)
    {
        case EBuildProfile::Debug:
            CHECK(kMinSeverity == ESeverity::Trace);
            CHECK(kAssertionsEnabled);
            CHECK(kValidationEnabled);
            break;
        case EBuildProfile::Development:
            CHECK(kMinSeverity == ESeverity::Info);
            CHECK(kAssertionsEnabled);
            CHECK(kValidationEnabled);
            break;
        case EBuildProfile::Shipping:
            CHECK(kMinSeverity == ESeverity::Warning);
            CHECK_FALSE(kAssertionsEnabled);
            CHECK_FALSE(kValidationEnabled);
            break;
    }
}

TEST_CASE("a passing assertion does nothing, and a compiled-out one does not evaluate its condition")
{
    int evaluations = 0;
    AETHER_ASSERT(++evaluations == 1, "passes");
    CHECK(evaluations == (kAssertionsEnabled ? 1 : 0));
}

TEST_CASE("a verification always evaluates its condition")
{
    int evaluations = 0;
    AETHER_VERIFY(++evaluations == 1, "passes {}", 1);
    CHECK(evaluations == 1);
}

TEST_CASE("an assertion without a message compiles, and its failure logs the expression alone")
{
    const auto run = runHelper("assert-no-message");
    if constexpr (kAssertionsEnabled)
    {
        CHECK(run.status != 0);
        CHECK(run.output.contains("[fatal] [assert] assertion failed: argc == 42 (assert_helper.cpp:"));
    }
    else
    {
        CHECK(run.status == 0);
    }
}

TEST_CASE("a failing assertion logs a fatal record with the expression, message and location, then fails")
{
    const auto run = runHelper("assert");
    if constexpr (kAssertionsEnabled)
    {
        CHECK(run.status != 0);
        CHECK(run.output.contains("[fatal] [assert] assertion failed: argc == 42: value 7"));
        CHECK(run.output.contains("assert_helper.cpp:"));
        CHECK_FALSE(run.output.contains("survived"));
    }
    else
    {
        CHECK(run.status == 0);
        CHECK(run.output.contains("survived"));
    }
}

TEST_CASE("a failing verification fails where checked, and only evaluates where compiled out")
{
    const auto run = runHelper("verify");
    if constexpr (kAssertionsEnabled)
    {
        CHECK(run.status != 0);
        CHECK(run.output.contains("assertion failed: argc == 42"));
    }
    else
    {
        CHECK(run.status == 0);
    }
}

TEST_CASE("reaching an unreachable point fails where checked")
{
    if constexpr (kAssertionsEnabled)
    {
        const auto run = runHelper("unreachable");
        CHECK(run.status != 0);
        CHECK(run.output.contains("assertion failed: unreachable: never here"));
    }
}

}  // namespace aether::core
