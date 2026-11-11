# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# SPDX-License-Identifier: MPL-2.0
# Docs:
#   - https://cmake.org/cmake/help/v4.1/command/string.html#json
#   - https://llvm.org/docs/CommandGuide/llvm-cov.html

# Script of the `coverage` target (see Coverage.cmake), run with cmake -P. It takes BUILD_DIR, SOURCE_DIR,
# CTEST, LLVM_COV, LLVM_PROFDATA, OBJECTS (the instrumented binaries, each followed by "|"), and the
# MIN_LINES, MIN_FUNCTIONS and MIN_BRANCHES thresholds.

set(out "${BUILD_DIR}/coverage")
file(REMOVE_RECURSE "${out}")
file(MAKE_DIRECTORY "${out}")

# One profile per process (%p), so the child processes of the tests write theirs.
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "LLVM_PROFILE_FILE=${out}/raw/%p.profraw" "${CTEST}" --test-dir "${BUILD_DIR}" --output-on-failure
    RESULT_VARIABLE status
)
if(NOT status EQUAL 0)
    message(FATAL_ERROR "The tests failed, so there is no coverage to measure")
endif()

file(GLOB raw_profiles "${out}/raw/*.profraw")
execute_process(
    COMMAND "${LLVM_PROFDATA}" merge -sparse ${raw_profiles} -o "${out}/coverage.profdata"
    COMMAND_ERROR_IS_FATAL ANY
)

# The report covers sources/ only: no tests, no dependencies.
file(GLOB_RECURSE sources "${SOURCE_DIR}/sources/*.cpp" "${SOURCE_DIR}/sources/*.hpp")
string(REPLACE "|" ";" objects "${OBJECTS}")
list(POP_BACK objects)
list(POP_FRONT objects first_object)
set(arguments -instr-profile "${out}/coverage.profdata" "${first_object}")
foreach(object IN LISTS objects)
    list(APPEND arguments -object "${object}")
endforeach()
list(APPEND arguments ${sources})

execute_process(COMMAND "${LLVM_COV}" report ${arguments} COMMAND_ERROR_IS_FATAL ANY)
execute_process(
    COMMAND "${LLVM_COV}" show -format=html "-output-dir=${out}/html" ${arguments}
    COMMAND_ERROR_IS_FATAL ANY
)
execute_process(
    COMMAND "${LLVM_COV}" export -summary-only ${arguments}
    OUTPUT_VARIABLE summary
    COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "HTML report: ${out}/html/index.html")

# Integer arithmetic only: covered * 100 < minimum * count.
set(failed FALSE)
foreach(kind lines functions branches)
    string(JSON covered GET "${summary}" data 0 totals ${kind} covered)
    string(JSON count GET "${summary}" data 0 totals ${kind} count)
    string(TOUPPER ${kind} upper)
    math(EXPR actual "${covered} * 100 / ${count}")
    math(EXPR scaled "${covered} * 100")
    math(EXPR required "${MIN_${upper}} * ${count}")
    if(scaled LESS required)
        message(SEND_ERROR "${kind} coverage is ${covered}/${count} (${actual} %), below the minimum of ${MIN_${upper}} %")
        set(failed TRUE)
    else()
        message(STATUS "${kind} coverage is ${covered}/${count} (${actual} %), minimum ${MIN_${upper}} %")
    endif()
endforeach()
if(failed)
    message(FATAL_ERROR "The code coverage is below the minimum")
endif()
