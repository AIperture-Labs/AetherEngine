# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://cmake.org/cmake/help/v4.1/index.html


include(ExternalProject)

option(AETHER_ENGINE_GIT_SUBMODULE "Check submodules during build" ON)

# GLM
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/glm)

# YASM (needed for libjpeg-turbo for SIMD optimisations)
add_subdirectory(${AETHER_ENGINE_EXTERN_DIR}/yasm)

# ExternalProject_Add(
#     libjpeg-turbo
#     GIT_REPOSITORY https://github.com/libjpeg-turbo/libjpeg-turbo
#     GIT_TAG 3.1.3
#     CMAKE_ARGS
#         -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/libjpeg-turbo
#         -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
#         -DENABLE_SHARED=ON
#         -DENABLE_STATIC=ON
#         -DWITH_TURBOJPEG=ON
#     BUILD_BYPRODUCTS
#         ${CMAKE_BINARY_DIR}/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
#         ${CMAKE_BINARY_DIR}/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX}
# )

# # Set paths for downstream targets
# set(JPEG_INCLUDE_DIR ${CMAKE_BINARY_DIR}/libjpeg-turbo/include)
# set(JPEG_LIBRARY ${CMAKE_BINARY_DIR}/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jpeg${CMAKE_STATIC_LIBRARY_SUFFIX})
# set(TURBOJPEG_LIBRARY ${CMAKE_BINARY_DIR}/libjpeg-turbo/lib/${CMAKE_STATIC_LIBRARY_PREFIX}turbojpeg${CMAKE_STATIC_LIBRARY_SUFFIX})