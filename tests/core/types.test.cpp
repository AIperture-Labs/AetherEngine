// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0

#include <doctest/doctest.h>

#include <aether/core/types.hpp>
#include <glm/ext/quaternion_float.hpp>
#include <glm/ext/vector_float3.hpp>
#include <type_traits>

// The tests assert literal sizes, which are the point.
// NOLINTBEGIN(cppcoreguidelines-avoid-magic-numbers)
namespace aether::core {

static_assert(sizeof(i8) == 1 && sizeof(i16) == 2 && sizeof(i32) == 4 && sizeof(i64) == 8);
static_assert(sizeof(u8) == 1 && sizeof(u16) == 2 && sizeof(u32) == 4 && sizeof(u64) == 8);
static_assert(sizeof(f32) == 4 && sizeof(f64) == 8);
static_assert(std::is_signed_v<i32> && std::is_unsigned_v<u32>);
static_assert(std::is_same_v<usize, decltype(sizeof(int))>);
static_assert(std::is_same_v<Vec3, glm::vec3>);
static_assert(std::is_same_v<Quat, glm::quat>);

TEST_CASE("integer aliases have the expected sizes")
{
    CHECK(sizeof(i8) == 1);
    CHECK(sizeof(i16) == 2);
    CHECK(sizeof(i32) == 4);
    CHECK(sizeof(i64) == 8);
    CHECK(sizeof(u8) == 1);
    CHECK(sizeof(u16) == 2);
    CHECK(sizeof(u32) == 4);
    CHECK(sizeof(u64) == 8);
}

TEST_CASE("floating point aliases have the expected sizes")
{
    CHECK(sizeof(f32) == 4);
    CHECK(sizeof(f64) == 8);
}

TEST_CASE("math aliases have the expected sizes")
{
    CHECK(sizeof(Vec2) == 2 * sizeof(f32));
    CHECK(sizeof(Vec3) == 3 * sizeof(f32));
    CHECK(sizeof(Vec4) == 4 * sizeof(f32));
    CHECK(sizeof(Mat3) == 9 * sizeof(f32));
    CHECK(sizeof(Mat4) == 16 * sizeof(f32));
    CHECK(sizeof(Quat) == 4 * sizeof(f32));
}

TEST_CASE("math aliases are usable as glm types")
{
    const Vec3 sum = Vec3(1.0F, 2.0F, 3.0F) + Vec3(1.0F);
    CHECK(sum == Vec3(2.0F, 3.0F, 4.0F));
    CHECK(Mat4(1.0F) * Vec4(1.0F, 2.0F, 3.0F, 1.0F) == Vec4(1.0F, 2.0F, 3.0F, 1.0F));
    CHECK(Quat(1.0F, 0.0F, 0.0F, 0.0F).w == 1.0F);
}

}  // namespace aether::core

// NOLINTEND(cppcoreguidelines-avoid-magic-numbers)
