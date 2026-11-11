// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0
// Doc: https://en.cppreference.com/w/cpp/utility/format/format

#pragma once

#include <aether/core/error.hpp>
#include <aether/core/export.hpp>
#include <aether/core/types.hpp>
#include <atomic>
#include <chrono>
#include <filesystem>
#include <format>
#include <memory>
#include <source_location>
#include <string>
#include <string_view>
#include <type_traits>
#include <utility>

namespace aether::core {

enum class ESeverity : u8 { Trace, Debug, Info, Warning, Error, Fatal };

// Build-wide: define AETHER_LOG_MIN_SEVERITY as an ESeverity enumerator (e.g. Warning) to compile out the calls below
// it.
#ifdef AETHER_LOG_MIN_SEVERITY
inline constexpr ESeverity kMinSeverity = ESeverity::AETHER_LOG_MIN_SEVERITY;
#else
inline constexpr ESeverity kMinSeverity = ESeverity::Trace;
#endif

// One per module, alive for the whole program: records keep a view of its name.
struct Category
{
    std::string_view       name;
    std::atomic<ESeverity> minSeverity{ESeverity::Trace};
};

struct LogRecord
{
    ESeverity                             severity;
    std::string_view                      category;
    std::string                           message;
    std::chrono::system_clock::time_point time;
    std::source_location                  location;
};

// Called one record at a time, under the dispatcher's lock.
class ISink
{
public:
    ISink()                         = default;
    ISink(const ISink &)            = delete;
    ISink(ISink &&)                 = delete;
    ISink &operator=(const ISink &) = delete;
    ISink &operator=(ISink &&)      = delete;
    virtual ~ISink()                = default;

    virtual void write(const LogRecord &record) = 0;
    virtual void flush()                        = 0;
};

// A checked format string that also captures the location of the log call.
template <typename... TArgs>
struct LogFormat
{
    template <typename T>
    // Implicit, so that a log call takes a plain string literal.
    // NOLINTNEXTLINE(cppcoreguidelines-explicit-constructor)
    consteval LogFormat(const T &format, std::source_location location = std::source_location::current()) :
        format(format), location(location)
    {
    }

    std::format_string<TArgs...> format;
    std::source_location         location;
};

AETHER_CORE_API void addSink(std::shared_ptr<ISink> sink);
AETHER_CORE_API void removeSink(const std::shared_ptr<ISink> &sink);

// Dispatches the record to every sink, then flushes them if it is fatal.
AETHER_CORE_API void submit(LogRecord record);
AETHER_CORE_API void flush();

// "<UTC time> [<severity>] [<category>] <message> (<file>:<line>)"
AETHER_CORE_API std::string formatRecord(const LogRecord &record);

// Writes to std::clog.
AETHER_CORE_API std::shared_ptr<ISink> makeConsoleSink();
// Truncates the file; fails with EErrorCode::IoError if it cannot be opened.
[[nodiscard]]
AETHER_CORE_API Result<std::shared_ptr<ISink>> makeFileSink(const std::filesystem::path &path);

template <ESeverity S, typename... TArgs>
void log(const Category &category, LogFormat<std::type_identity_t<TArgs>...> format, TArgs &&...args)
{
    if constexpr (S >= kMinSeverity)
    {
        if (S >= category.minSeverity.load(std::memory_order_relaxed))
        {
            submit({S,
                    category.name,
                    std::format(format.format, std::forward<TArgs>(args)...),
                    std::chrono::system_clock::now(),
                    format.location});
        }
    }
}

}  // namespace aether::core

// Log through these macros: below kMinSeverity they compile out the call and its arguments, which a function cannot.
// NOLINTBEGIN(cppcoreguidelines-macro-usage)
#define AETHER_LOG(severity, category, ...)                                              \
    if constexpr (::aether::core::ESeverity::severity >= ::aether::core::kMinSeverity)   \
        ::aether::core::log<::aether::core::ESeverity::severity>(category, __VA_ARGS__); \
    else                                                                                 \
        static_cast<void>(0)

#define AETHER_LOG_TRACE(category, ...) AETHER_LOG(Trace, category, __VA_ARGS__)
#define AETHER_LOG_DEBUG(category, ...) AETHER_LOG(Debug, category, __VA_ARGS__)
#define AETHER_LOG_INFO(category, ...) AETHER_LOG(Info, category, __VA_ARGS__)
#define AETHER_LOG_WARNING(category, ...) AETHER_LOG(Warning, category, __VA_ARGS__)
#define AETHER_LOG_ERROR(category, ...) AETHER_LOG(Error, category, __VA_ARGS__)
#define AETHER_LOG_FATAL(category, ...) AETHER_LOG(Fatal, category, __VA_ARGS__)
// NOLINTEND(cppcoreguidelines-macro-usage)
