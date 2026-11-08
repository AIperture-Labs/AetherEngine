// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0
// Docs: https://en.cppreference.com/w/cpp/utility/expected

#pragma once

#include <expected>
#include <source_location>
#include <string>
#include <utility>

namespace aether::core {

enum class ErrorCode {
    Unknown,
    InvalidArgument,
    NotFound,
    OutOfRange,
    Unsupported,
    IoError,
};

struct Error
{
    ErrorCode            code = ErrorCode::Unknown;
    std::string          message;
    std::source_location location;
};

template <typename T>
using Result = std::expected<T, Error>;

using Status = Result<void>;

// Returns an `std::unexpected` so it converts to any Result<T> or Status; the location is the caller's.
[[nodiscard]] inline std::unexpected<Error> makeError(ErrorCode            code,
                                                      std::string          message,
                                                      std::source_location location = std::source_location::current())
{
    return std::unexpected<Error>(Error{.code = code, .message = std::move(message), .location = location});
}

}  // namespace aether::core
