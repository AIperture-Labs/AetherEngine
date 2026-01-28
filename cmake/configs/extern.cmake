# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://cmake.org/cmake/help/v4.1/index.html


include(ExternalProject)


# GLM
message(STATUS "Configuring extern lib: GLM")
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/glm)

# YASM (needed for libjpeg-turbo for SIMD optimisations)
message(STATUS "Configuring extern lib: Yasm")
# find_package(Yasm 1.3.0 REQUIRED)
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/yasm)

# libjpeg-turbo - High-performance JPEG codec
message(STATUS "Configuring extern lib: libjpeg-turbo")
ExternalProject_Add(
    libjpeg-turbo
    SOURCE_DIR ${AETHER_ENGINE_EXTERN_DIR}/libjpeg-turbo
    BINARY_DIR ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo-build
    INSTALL_DIR ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    # Library options
    -DENABLE_SHARED=ON
    -DENABLE_STATIC=ON
    # Features
    -DWITH_TURBOJPEG=ON
    -DWITH_SIMD=ON
    -DWITH_ARITH_ENC=ON
    -DWITH_ARITH_DEC=ON
    # Disable unnecessary components
    -DWITH_JAVA=OFF
    -DWITH_TOOLS=OFF
    -DWITH_TESTS=OFF
    -DWITH_FUZZ=OFF
    BUILD_BYPRODUCTS
    # Static libraries
    ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
    ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
    # Shared libraries
    ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/bin/${CMAKE_SHARED_LIBRARY_PREFIX}jpeg${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/bin/${CMAKE_SHARED_LIBRARY_PREFIX}turbojpeg${CMAKE_SHARED_LIBRARY_SUFFIX}
)

# Set paths for downstream targets
set(JPEG_INCLUDE_DIR ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/include CACHE PATH "libjpeg-turbo include directory")
# Static libraries
set(JPEG_LIBRARY ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE FILEPATH "libjpeg static library")
set(TURBOJPEG_LIBRARY ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE FILEPATH "TurboJPEG static library")
# Shared libraries
set(JPEG_SHARED_LIBRARY ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/bin/${CMAKE_SHARED_LIBRARY_PREFIX}jpeg${CMAKE_SHARED_LIBRARY_SUFFIX} CACHE FILEPATH "libjpeg shared library")
set(TURBOJPEG_SHARED_LIBRARY ${CMAKE_BINARY_DIR}/extern/libjpeg-turbo/bin/${CMAKE_SHARED_LIBRARY_PREFIX}turbojpeg${CMAKE_SHARED_LIBRARY_SUFFIX} CACHE FILEPATH "TurboJPEG shared library")
