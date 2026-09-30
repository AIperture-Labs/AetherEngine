# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs: 
#   - https://cmake.org/cmake/help/v4.1/index.html
#   - https://cliutils.gitlab.io/modern-cmake/README.html
#   - https://github.com/doctest/doctest/blob/master/doc/markdown/build-systems.md

# doctest is consumed as a submodule (see Dependencies.cmake), which defines the
# doctest::doctest target and exports DOCTEST_CMAKE_HELPER, the absolute path to its
# doctest_discover_tests() helper. Neither find_package(doctest) nor include(doctest) works in
# that mode: no package config is installed and the scripts folder is not on CMAKE_MODULE_PATH.
if(NOT TARGET doctest::doctest)
    message(FATAL_ERROR "[Doctest] doctest::doctest is missing. Include Dependencies.cmake first.")
endif()

include("${DOCTEST_CMAKE_HELPER}")

#[=======================================================================[.rst:
add_doctest
-----------

Declares a doctest executable and registers its test cases with CTest.

Synopsis
^^^^^^^^

.. code-block:: cmake

  add_doctest(
    NAME <name>
    SOURCES <source>...
    [LIBS <library>...]
  )

Description
^^^^^^^^^^^

This function builds ``<name>`` from ``SOURCES``, links it against ``doctest::doctest`` plus any
library given in ``LIBS``, and calls ``doctest_discover_tests()`` so that every ``TEST_CASE`` in
the binary becomes an individual CTest test named ``<name>/<test case>``.

Arguments
^^^^^^^^^

``NAME <name>``
  Name of the test executable. Required.

``SOURCES <source>...``
  Source files making up the test executable. Required.

``LIBS <library>...``
  Extra libraries to link against, typically the component under test.

Example
^^^^^^^

.. code-block:: cmake

  add_doctest(
    NAME core_tests
    SOURCES core/version.test.cpp
    LIBS AetherEngine::core
  )

#]=======================================================================]
function(add_doctest)
    cmake_parse_arguments(
        DOCTEST
        ""
        "NAME"
        "SOURCES;LIBS"
        ${ARGN}
    )

    if(NOT DOCTEST_NAME)
        message(FATAL_ERROR "[add_doctest] NAME is required")
    endif()

    if(NOT DOCTEST_SOURCES)
        message(FATAL_ERROR "[add_doctest] SOURCES is required")
    endif()

    add_executable(${DOCTEST_NAME}
        ${DOCTEST_SOURCES}
    )

    target_link_libraries(${DOCTEST_NAME}
        PRIVATE
        doctest::doctest
        ${DOCTEST_LIBS}
    )

    doctest_discover_tests(${DOCTEST_NAME}
        WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        TEST_PREFIX ${DOCTEST_NAME}/
    )
endfunction()
