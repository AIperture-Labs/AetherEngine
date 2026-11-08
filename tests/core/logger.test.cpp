// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <doctest/doctest.h>

#include <aether/core/logger.hpp>
#include <algorithm>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <memory>
#include <regex>
#include <sstream>
#include <string>
#include <thread>
#include <utility>
#include <vector>

// The tests assert literal values, which are the point.
// NOLINTBEGIN(cppcoreguidelines-avoid-magic-numbers)
namespace aether::core {

namespace {

struct CapturingSink final : Sink
{
    std::vector<LogRecord> records;
    int                    flushes = 0;

    void write(const LogRecord &record) override
    {
        records.push_back(record);
    }

    void flush() override
    {
        ++flushes;
    }
};

// Keeps a sink registered for the scope of a test.
class SinkGuard
{
public:
    explicit SinkGuard(std::shared_ptr<Sink> sink) : sink_(std::move(sink))
    {
        addSink(sink_);
    }

    SinkGuard(const SinkGuard &)            = delete;
    SinkGuard(SinkGuard &&)                 = delete;
    SinkGuard &operator=(const SinkGuard &) = delete;
    SinkGuard &operator=(SinkGuard &&)      = delete;

    ~SinkGuard()
    {
        removeSink(sink_);
    }

private:
    std::shared_ptr<Sink> sink_;
};

std::filesystem::path tempLog(std::string_view name)
{
    return std::filesystem::temp_directory_path() / std::format("aether_core_tests_{}.log", name);
}

std::vector<std::string> readLines(const std::filesystem::path &path)
{
    std::ifstream            file(path);
    std::vector<std::string> lines;
    for (std::string line; std::getline(file, line);)
    {
        lines.push_back(line);
    }
    return lines;
}

}  // namespace

TEST_CASE("a log call submits a record with its severity, category, message, time and location")
{
    const auto      sink = std::make_shared<CapturingSink>();
    const SinkGuard guard(sink);
    const Category  category{.name = "test"};

    const auto before = std::chrono::system_clock::now();
    const auto line   = std::source_location::current().line() + 1;
    log<Severity::Info>(category, "{} + {} = {}", 1, 2, 3);
    const auto after = std::chrono::system_clock::now();

    REQUIRE(sink->records.size() == 1);
    const LogRecord &record = sink->records.front();
    CHECK(record.severity == Severity::Info);
    CHECK(record.category == "test");
    CHECK(record.message == "1 + 2 = 3");
    CHECK(record.time >= before);
    CHECK(record.time <= after);
    CHECK(record.location.line() == line);
}

TEST_CASE("records below the minimum severity of their category are dropped")
{
    const auto      sink = std::make_shared<CapturingSink>();
    const SinkGuard guard(sink);
    Category        category{.name = "test"};
    category.minSeverity = Severity::Warning;

    log<Severity::Info>(category, "dropped");
    log<Severity::Warning>(category, "kept");
    log<Severity::Error>(category, "kept");

    REQUIRE(sink->records.size() == 2);
    CHECK(sink->records.at(0).severity == Severity::Warning);
    CHECK(sink->records.at(1).severity == Severity::Error);
}

TEST_CASE("the minimum severity of a category does not filter the other categories")
{
    const auto      sink = std::make_shared<CapturingSink>();
    const SinkGuard guard(sink);
    Category        audio{.name = "audio"};
    const Category  render{.name = "render"};
    audio.minSeverity = Severity::Fatal;

    log<Severity::Error>(audio, "muted");
    log<Severity::Info>(render, "shown");

    REQUIRE(sink->records.size() == 1);
    CHECK(sink->records.at(0).category == "render");
}

TEST_CASE("a record is formatted as UTC time, severity, category, message and file location")
{
    using namespace std::chrono_literals;
    const auto      location = std::source_location::current();
    const LogRecord record{
        .severity = Severity::Warning,
        .category = "core",
        .message  = "low memory",
        .time     = std::chrono::sys_days{std::chrono::year{2026} / 11 / 8} + 18h + 5min + 24s + 123456us,
        .location = location,
    };

    CHECK(formatRecord(record) ==
          std::format("2026-11-08 18:05:24.123 [warning] [core] low memory (logger.test.cpp:{})", location.line()));
}

TEST_CASE("flush flushes every sink, and a fatal record flushes them too")
{
    const auto      sink = std::make_shared<CapturingSink>();
    const SinkGuard guard(sink);
    const Category  category{.name = "test"};

    flush();
    CHECK(sink->flushes == 1);
    log<Severity::Error>(category, "not flushed");
    CHECK(sink->flushes == 1);
    log<Severity::Fatal>(category, "flushed");
    CHECK(sink->flushes == 2);
    CHECK(sink->records.size() == 2);
}

TEST_CASE("the console sink writes formatted lines to std::clog")
{
    const Category     category{.name = "console"};
    std::ostringstream output;
    auto              *previous = std::clog.rdbuf(output.rdbuf());
    {
        const SinkGuard guard(makeConsoleSink());
        log<Severity::Info>(category, "hello");
        flush();
    }
    std::clog.rdbuf(previous);

    CHECK(output.str().contains("[info] [console] hello (logger.test.cpp:"));
    CHECK(output.str().ends_with(")\n"));
}

TEST_CASE("the file sink writes one formatted line per record")
{
    const auto     path = tempLog("file_sink");
    const Category category{.name = "file"};
    {
        const SinkGuard guard(makeFileSink(path));
        log<Severity::Info>(category, "first");
        log<Severity::Error>(category, "second {}", 2);
        flush();

        const auto lines = readLines(path);
        REQUIRE(lines.size() == 2);
        CHECK(lines.at(0).contains("[info] [file] first (logger.test.cpp:"));
        CHECK(lines.at(1).contains("[error] [file] second 2 (logger.test.cpp:"));
    }
    std::filesystem::remove(path);
}

TEST_CASE("concurrent log calls write whole lines that never interleave")
{
    constexpr int  kThreads = 8;
    constexpr int  kLines   = 250;
    const auto     path     = tempLog("threads");
    const Category category{.name = "threads"};
    {
        const SinkGuard guard(makeFileSink(path));
        {
            std::vector<std::jthread> threads;
            for (int thread = 0; thread < kThreads; ++thread)
            {
                threads.emplace_back([&category, thread] {
                    for (int line = 0; line < kLines; ++line)
                    {
                        log<Severity::Info>(category, "thread {} line {}", thread, line);
                    }
                });
            }
        }
        flush();

        const auto       lines = readLines(path);
        const std::regex pattern(R"(\S+ \S+ \[info\] \[threads\] thread \d+ line \d+ \(logger\.test\.cpp:\d+\))");
        CHECK(lines.size() == kThreads * kLines);
        CHECK(std::ranges::all_of(lines,
                                  [&pattern](const std::string &line) { return std::regex_match(line, pattern); }));
    }
    std::filesystem::remove(path);
}

}  // namespace aether::core

// NOLINTEND(cppcoreguidelines-avoid-magic-numbers)
