// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0
// Doc: docs/development.md

#pragma once

#include <aether/core/types.hpp>

namespace aether::core {

enum class EBuildProfile : u8 { Debug, Development, Shipping };

// The definitions come from AETHER_BUILD_PROFILE (cmake/helpers/BuildProfile.cmake).
#if defined(AETHER_PROFILE_DEBUG)
inline constexpr EBuildProfile kBuildProfile = EBuildProfile::Debug;
#elif defined(AETHER_PROFILE_DEVELOPMENT)
inline constexpr EBuildProfile kBuildProfile = EBuildProfile::Development;
#elif defined(AETHER_PROFILE_SHIPPING)
inline constexpr EBuildProfile kBuildProfile = EBuildProfile::Shipping;
#else
#    error "No build profile: define AETHER_PROFILE_DEBUG, AETHER_PROFILE_DEVELOPMENT or AETHER_PROFILE_SHIPPING"
#endif

inline constexpr bool kAssertionsEnabled = AETHER_ASSERTIONS != 0;
inline constexpr bool kValidationEnabled = AETHER_VALIDATION != 0;

}  // namespace aether::core
