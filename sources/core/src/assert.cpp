// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <aether/core/assert.hpp>
#include <aether/core/logger.hpp>
#include <chrono>
#include <cstdlib>
#include <utility>

#ifdef AETHER_COVERAGE
// The profile runtime of Clang; the trap below kills the process before it writes its profile.
// NOLINTNEXTLINE(bugprone-reserved-identifier,readability-identifier-naming,cert-dcl37-c,cert-dcl51-cpp)
extern "C" int __llvm_profile_write_file();
#endif

namespace aether::core {

namespace {

constexpr std::string_view kCategory = "assert";

}  // namespace

void assertionFailed(std::string_view expression, std::source_location location, const std::string &message)
{
    auto text = std::format("assertion failed: {}", expression);
    if (!message.empty())
    {
        text += ": " + message;
    }
    submit({.severity = ESeverity::Fatal,
            .category = kCategory,
            .message  = std::move(text),
            .time     = std::chrono::system_clock::now(),
            .location = location});
#ifdef AETHER_COVERAGE
    __llvm_profile_write_file();
#endif
    // Without a debugger, the trap kills the process like abort() does; with one, it stops at the failure.
    __builtin_debugtrap();
    std::abort();
}

}  // namespace aether::core
