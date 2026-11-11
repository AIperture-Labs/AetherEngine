// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <aether/core/assert.hpp>
#include <aether/core/logger.hpp>
#include <cstdlib>
#include <iostream>
#include <span>
#include <string_view>

// Fails the way its argument says, so that assert.test.cpp can run it as a child process.
// The format strings of the messages are checked at compile time: std::format cannot throw here.
// NOLINTNEXTLINE(bugprone-exception-escape)
int main(int argc, char **argv)
{
    using namespace aether::core;

    addSink(makeConsoleSink());
    const std::span        args(argv, static_cast<std::size_t>(argc));
    const std::string_view mode = args.size() > 1 ? args.subspan(1).front() : "";
    if (mode == "assert")
    {
        AETHER_ASSERT(argc == 42, "value {}", 7);
    }
    else if (mode == "assert-no-message")
    {
        AETHER_ASSERT(argc == 42);
    }
    else if (mode == "verify")
    {
        AETHER_VERIFY(argc == 42);
    }
    else if (mode == "unreachable")
    {
        AETHER_UNREACHABLE("never {}", "here");
    }
    std::cerr << "survived\n";
    return EXIT_SUCCESS;
}
