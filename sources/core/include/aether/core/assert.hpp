// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0
// Doc: https://clang.llvm.org/docs/LanguageExtensions.html#builtin-debugtrap

#pragma once

#include <aether/core/export.hpp>
#include <aether/core/profile.hpp>  // IWYU pragma: keep, the macros below use it
#include <format>
#include <source_location>
#include <string>
#include <string_view>
#include <utility>

namespace aether::core {

// Logs the failure at fatal level (which flushes the sinks), then breaks into the debugger if there is one, else
// aborts.
[[noreturn]]
AETHER_CORE_API void assertionFailed(std::string_view     expression,
                                     std::source_location location,
                                     const std::string   &message = {});

template <typename... TArgs>
std::string formatMessage(std::format_string<TArgs...> format, TArgs &&...args)
{
    return std::format(format, std::forward<TArgs>(args)...);
}

}  // namespace aether::core

// AETHER_ASSERT(cond, "format", args...): checked where kAssertionsEnabled, compiled out otherwise, condition included.
// AETHER_VERIFY: the same, but the condition is always evaluated.
// AETHER_UNREACHABLE(): a failure where checked, an optimiser hint otherwise.
// The message is optional.
// NOLINTBEGIN(cppcoreguidelines-macro-usage)
// Internal to the macros below: it has no else branch, so it is not safe to use alone.
#define AETHER_DETAIL_ASSERT_CHECK(cond, ...)                                                          \
    if (!(cond))                                                                                       \
    {                                                                                                  \
        ::aether::core::assertionFailed(#cond,                                                         \
                                        std::source_location::current()                                \
                                            __VA_OPT__(, ::aether::core::formatMessage(__VA_ARGS__))); \
    }

#define AETHER_ASSERT(cond, ...)                      \
    if constexpr (::aether::core::kAssertionsEnabled) \
    {                                                 \
        AETHER_DETAIL_ASSERT_CHECK(cond, __VA_ARGS__) \
    }                                                 \
    else                                              \
        static_cast<void>(0)

#define AETHER_VERIFY(cond, ...)                      \
    if constexpr (::aether::core::kAssertionsEnabled) \
    {                                                 \
        AETHER_DETAIL_ASSERT_CHECK(cond, __VA_ARGS__) \
    }                                                 \
    else                                              \
        static_cast<void>(cond)

#define AETHER_UNREACHABLE(...)                                                                        \
    if constexpr (::aether::core::kAssertionsEnabled)                                                  \
        ::aether::core::assertionFailed("unreachable",                                                 \
                                        std::source_location::current()                                \
                                            __VA_OPT__(, ::aether::core::formatMessage(__VA_ARGS__))); \
    else                                                                                               \
        std::unreachable()
// NOLINTEND(cppcoreguidelines-macro-usage)
