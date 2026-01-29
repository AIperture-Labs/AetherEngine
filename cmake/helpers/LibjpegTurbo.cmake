# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Helper function for building libjpeg-turbo via ExternalProject

include(ExternalProject)

#[=======================================================================[.rst:
ConfigureLibjpegTurbo
---------------------

Configures and builds libjpeg-turbo using ExternalProject_Add.
All build options are controlled from Config.cmake via JPEG_* variables.

This function sets the following cache variables for downstream targets:
  - JPEG_INCLUDE_DIR: Include directory
  - JPEG_LIBRARY: Static libjpeg library
  - TURBOJPEG_LIBRARY: Static TurboJPEG library
  - JPEG_SHARED_LIBRARY: Shared libjpeg library
  - TURBOJPEG_SHARED_LIBRARY: Shared TurboJPEG library

#]=======================================================================]

function(ConfigureLibjpegTurbo)
    message(STATUS "Configuring extern lib: libjpeg-turbo")

    # Set installation directory
    set(JPEG_INSTALL_DIR ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo)
    message(STATUS "  Install directory: ${JPEG_INSTALL_DIR}")
    message(STATUS "  Source directory: ${AETHER_ENGINE_EXTERN_DIR}/libjpeg-turbo")

    # Log configuration options
    message(STATUS "  Build configuration:")
    message(STATUS "    Shared libraries: ${JPEG_ENABLE_SHARED}")
    message(STATUS "    Static libraries: ${JPEG_ENABLE_STATIC}")
    message(STATUS "    TurboJPEG API: ${JPEG_WITH_TURBOJPEG}")
    message(STATUS "    SIMD optimizations: ${JPEG_WITH_SIMD}")
    message(STATUS "    Arithmetic coding (enc/dec): ${JPEG_WITH_ARITH_ENC}/${JPEG_WITH_ARITH_DEC}")
    if(JPEG_WITH_JPEG7 OR JPEG_WITH_JPEG8)
        message(STATUS "    API/ABI emulation: JPEG${JPEG_WITH_JPEG7}${JPEG_WITH_JPEG8}")
    endif()

    # Build libjpeg-turbo using ExternalProject
    # Options are controlled from Config.cmake (JPEG_* variables)
    ExternalProject_Add(
        libjpeg-turbo
        SOURCE_DIR ${AETHER_ENGINE_EXTERN_DIR}/libjpeg-turbo
        BINARY_DIR ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo-build
        INSTALL_DIR ${JPEG_INSTALL_DIR}
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON
            # Library options (from Config.cmake)
            -DENABLE_SHARED=${JPEG_ENABLE_SHARED}
            -DENABLE_STATIC=${JPEG_ENABLE_STATIC}
            # API/ABI Emulation
            -DWITH_JPEG7=${JPEG_WITH_JPEG7}
            -DWITH_JPEG8=${JPEG_WITH_JPEG8}
            # Features
            -DWITH_TURBOJPEG=${JPEG_WITH_TURBOJPEG}
            -DWITH_SIMD=${JPEG_WITH_SIMD}
            -DREQUIRE_SIMD=${JPEG_REQUIRE_SIMD}
            -DWITH_ARITH_ENC=${JPEG_WITH_ARITH_ENC}
            -DWITH_ARITH_DEC=${JPEG_WITH_ARITH_DEC}
            # Build components
            -DWITH_JAVA=${JPEG_WITH_JAVA}
            -DWITH_TOOLS=${JPEG_WITH_TOOLS}
            -DWITH_TESTS=${JPEG_WITH_TESTS}
            -DWITH_FUZZ=${JPEG_WITH_FUZZ}
            # Performance
            -DFORCE_INLINE=${JPEG_FORCE_INLINE}
        BUILD_BYPRODUCTS
            # Static libraries
            ${JPEG_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
            ${JPEG_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
            # Shared libraries
            ${JPEG_INSTALL_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}jpeg${CMAKE_SHARED_LIBRARY_SUFFIX}
            ${JPEG_INSTALL_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}turbojpeg${CMAKE_SHARED_LIBRARY_SUFFIX}
    )

    # Set paths for downstream targets (promote to parent scope)

    # Log configured paths
    message(STATUS "  Output libraries will be available at:")
    if(JPEG_ENABLE_STATIC)
        message(STATUS "    Static: ${JPEG_LIBRARY}")
        message(STATUS "    Static (TurboJPEG): ${TURBOJPEG_LIBRARY}")
    endif()
    if(JPEG_ENABLE_SHARED)
        message(STATUS "    Shared: ${JPEG_SHARED_LIBRARY}")
        message(STATUS "    Shared (TurboJPEG): ${TURBOJPEG_SHARED_LIBRARY}")
    endif()
    message(STATUS "  Headers: ${JPEG_INCLUDE_DIR}")
    set(JPEG_INCLUDE_DIR ${JPEG_INSTALL_DIR}/include CACHE PATH "libjpeg-turbo include directory")
    # Static libraries
    set(JPEG_LIBRARY ${JPEG_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX} 
        CACHE FILEPATH "libjpeg static library")
    set(TURBOJPEG_LIBRARY ${JPEG_INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX} 
        CACHE FILEPATH "TurboJPEG static library")
    # Shared libraries
    set(JPEG_SHARED_LIBRARY ${JPEG_INSTALL_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}jpeg${CMAKE_SHARED_LIBRARY_SUFFIX} 
        CACHE FILEPATH "libjpeg shared library")
    set(TURBOJPEG_SHARED_LIBRARY ${JPEG_INSTALL_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}turbojpeg${CMAKE_SHARED_LIBRARY_SUFFIX} 
        CACHE FILEPATH "TurboJPEG shared library")
endfunction()
