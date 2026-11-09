// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <doctest/doctest.h>

#include <aether/core/error.hpp>
#include <aether/core/types.hpp>
#include <string_view>

namespace aether::core {

namespace {

Result<i32> parsePositive(i32 value)
{
    if (value <= 0)
    {
        return makeError(EErrorCode::InvalidArgument, "value must be positive");
    }
    return value;
}

Result<i32> doubled(i32 value)
{
    const Result<i32> parsed = parsePositive(value);
    if (!parsed)
    {
        return std::unexpected(parsed.error());
    }
    return *parsed * 2;
}

Status requirePositive(i32 value)
{
    const Result<i32> parsed = parsePositive(value);
    if (!parsed)
    {
        return std::unexpected(parsed.error());
    }
    return {};
}

}  // namespace

TEST_CASE("a successful Result holds its value")
{
    const Result<i32> result = parsePositive(3);
    REQUIRE(result.has_value());
    CHECK(*result == 3);
}

TEST_CASE("a failed Result holds the code and the message")
{
    const Result<i32> result = parsePositive(-1);
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == EErrorCode::InvalidArgument);
    CHECK(result.error().message == "value must be positive");
}

TEST_CASE("makeError records the location of its caller")
{
    const Result<i32> result = parsePositive(0);
    REQUIRE_FALSE(result.has_value());
    CHECK(std::string_view(result.error().location.file_name()).find("error.test.cpp") != std::string_view::npos);
    CHECK(std::string_view(result.error().location.function_name()).find("parsePositive") != std::string_view::npos);
    CHECK(result.error().location.line() > 0);
}

TEST_CASE("an error propagates to the caller unchanged")
{
    CHECK(*doubled(4) == 8);

    const Result<i32> result = doubled(-4);
    REQUIRE_FALSE(result.has_value());
    CHECK(result.error().code == EErrorCode::InvalidArgument);
    CHECK(std::string_view(result.error().location.function_name()).find("parsePositive") != std::string_view::npos);
}

TEST_CASE("a Status succeeds with no value")
{
    CHECK(requirePositive(1).has_value());
}

TEST_CASE("a Status fails with an error")
{
    const Status status = requirePositive(0);
    REQUIRE_FALSE(status.has_value());
    CHECK(status.error().code == EErrorCode::InvalidArgument);
}

TEST_CASE("a Result chains with the monadic operations")
{
    const Result<i32> result = parsePositive(5).and_then(doubled);
    REQUIRE(result.has_value());
    CHECK(*result == 10);
    CHECK_FALSE(parsePositive(-5).and_then(doubled).has_value());
}

}  // namespace aether::core
