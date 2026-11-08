// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <aether/core/logger.hpp>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <mutex>
#include <stdexcept>
#include <utility>
#include <vector>

namespace aether::core {

namespace {

// Synchronous: an asynchronous logger replaces this with a queue drained by a thread.
struct Dispatcher
{
    std::mutex                         mutex;
    std::vector<std::shared_ptr<Sink>> sinks;
};

Dispatcher &dispatcher()
{
    static Dispatcher instance;
    return instance;
}

std::string_view toString(Severity severity)
{
    switch (severity)
    {
        case Severity::Trace:
            return "trace";
        case Severity::Debug:
            return "debug";
        case Severity::Info:
            return "info";
        case Severity::Warning:
            return "warning";
        case Severity::Error:
            return "error";
        case Severity::Fatal:
            return "fatal";
    }
    std::unreachable();
}

class ConsoleSink final : public Sink
{
public:
    void write(const LogRecord &record) override
    {
        std::clog << formatRecord(record) << '\n';
    }

    void flush() override
    {
        std::clog.flush();
    }
};

class FileSink final : public Sink
{
public:
    explicit FileSink(const std::filesystem::path &path) : file_(path)
    {
        if (!file_)
        {
            throw std::runtime_error(std::format("cannot open the log file {}", path.string()));
        }
    }

    void write(const LogRecord &record) override
    {
        file_ << formatRecord(record) << '\n';
    }

    void flush() override
    {
        file_.flush();
    }

private:
    std::ofstream file_;
};

}  // namespace

void addSink(std::shared_ptr<Sink> sink)
{
    auto &[mutex, sinks] = dispatcher();
    const std::scoped_lock lock(mutex);
    sinks.push_back(std::move(sink));
}

void removeSink(const std::shared_ptr<Sink> &sink)
{
    auto &[mutex, sinks] = dispatcher();
    const std::scoped_lock lock(mutex);
    std::erase(sinks, sink);
}

void submit(LogRecord record)
{
    auto &[mutex, sinks] = dispatcher();
    const std::scoped_lock lock(mutex);
    for (const auto &sink : sinks)
    {
        sink->write(record);
    }
    if (record.severity == Severity::Fatal)
    {
        for (const auto &sink : sinks)
        {
            sink->flush();
        }
    }
}

void flush()
{
    auto &[mutex, sinks] = dispatcher();
    const std::scoped_lock lock(mutex);
    for (const auto &sink : sinks)
    {
        sink->flush();
    }
}

std::string formatRecord(const LogRecord &record)
{
    const std::string_view path = record.location.file_name();
    // npos + 1 wraps to 0: a path without a directory is kept whole.
    const std::string_view file = path.substr(path.find_last_of("/\\") + 1);
    return std::format("{:%F %T} [{}] [{}] {} ({}:{})",
                       std::chrono::floor<std::chrono::milliseconds>(record.time),
                       toString(record.severity),
                       record.category,
                       record.message,
                       file,
                       record.location.line());
}

std::shared_ptr<Sink> makeConsoleSink()
{
    return std::make_shared<ConsoleSink>();
}

std::shared_ptr<Sink> makeFileSink(const std::filesystem::path &path)
{
    return std::make_shared<FileSink>(path);
}

}  // namespace aether::core
