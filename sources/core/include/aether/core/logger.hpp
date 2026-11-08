// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0
// Doc: https://en.cppreference.com/w/cpp/utility/format/format

#pragma once

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

enum class Severity : u8 { Trace, Debug, Info, Warning, Error, Fatal };

// Build-wide: define AETHER_LOG_MIN_SEVERITY as a Severity enumerator (e.g. Warning) to compile out the calls below it.
#ifdef AETHER_LOG_MIN_SEVERITY
inline constexpr Severity kMinSeverity = Severity::AETHER_LOG_MIN_SEVERITY;
#else
inline constexpr Severity kMinSeverity = Severity::Trace;
#endif

// One per module, alive for the whole program: records keep a view of its name.
struct Category
{
    std::string_view      name;
    std::atomic<Severity> minSeverity{Severity::Trace};
};

struct LogRecord
{
    Severity                              severity;
    std::string_view                      category;
    std::string                           message;
    std::chrono::system_clock::time_point time;
    std::source_location                  location;
};

// Called one record at a time, under the dispatcher's lock.
class Sink
{
public:
    Sink()                        = default;
    Sink(const Sink &)            = delete;
    Sink(Sink &&)                 = delete;
    Sink &operator=(const Sink &) = delete;
    Sink &operator=(Sink &&)      = delete;
    virtual ~Sink()               = default;

    virtual void write(const LogRecord &record) = 0;
    virtual void flush()                        = 0;
};

// A checked format string that also captures the location of the log call.
template <typename... Args>
struct LogFormat
{
    template <typename T>
    // Implicit, so that a log call takes a plain string literal.
    // NOLINTNEXTLINE(cppcoreguidelines-explicit-constructor)
    consteval LogFormat(const T &format, std::source_location location = std::source_location::current()) :
        format(format), location(location)
    {
    }

    std::format_string<Args...> format;
    std::source_location        location;
};

AETHER_CORE_API void addSink(std::shared_ptr<Sink> sink);
AETHER_CORE_API void removeSink(const std::shared_ptr<Sink> &sink);

// Dispatches the record to every sink, then flushes them if it is fatal.
AETHER_CORE_API void submit(LogRecord record);
AETHER_CORE_API void flush();

// "<UTC time> [<severity>] [<category>] <message> (<file>:<line>)"
AETHER_CORE_API std::string formatRecord(const LogRecord &record);

// Writes to std::clog.
AETHER_CORE_API std::shared_ptr<Sink> makeConsoleSink();
// Truncates the file; throws std::runtime_error if it cannot be opened.
AETHER_CORE_API std::shared_ptr<Sink> makeFileSink(const std::filesystem::path &path);

template <Severity S, typename... Args>
void log(const Category &category, LogFormat<std::type_identity_t<Args>...> format, Args &&...args)
{
    if constexpr (S >= kMinSeverity)
    {
        if (S >= category.minSeverity.load(std::memory_order_relaxed))
        {
            submit({S,
                    category.name,
                    std::format(format.format, std::forward<Args>(args)...),
                    std::chrono::system_clock::now(),
                    format.location});
        }
    }
}

}  // namespace aether::core
