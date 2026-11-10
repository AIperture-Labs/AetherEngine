# Naming

How names are written in the engine. Read it to recognise what a name is in
the API, or before writing engine code. A name tells its kind and its scope,
so a diff reads right even without an IDE (a review on GitHub, on a phone).

| Element | Convention | Example |
| --- | --- | --- |
| Class, struct, type alias | `PascalCase` | `Texture`, `LogRecord` |
| Interface (abstract class) | `I` + `PascalCase` | `ISink` |
| Enum | `E` + `PascalCase` | `ESeverity` |
| Enum value | `PascalCase` | `ESeverity::Warning` |
| Type template parameter | `T` + `PascalCase` | `TValue`, `TArgs` |
| Function, method | `camelCase` | `loadTexture` |
| Local variable, parameter | `camelCase` | `frameCount` |
| Public member of a struct | `camelCase` | `record.message` |
| Private or protected member | `m_` + `camelCase` | `m_file` |
| Static member | `s_` + `camelCase` | `s_instance` |
| Global variable | `g_` + `camelCase` | `g_dispatcher` |
| Constant, `constexpr` | `k` + `PascalCase` | `kMaxLights` |
| Boolean | `b` + `PascalCase` | `bVisible`, `m_bDirty` |
| Macro | `AETHER_` + `UPPER_CASE` | `AETHER_ASSERT` |
| Namespace | `lower_case` | `aether::core` |

How to read it:

- An uppercase prefix marks a type (`E`, `I`, `T`), a lowercase one a value
  (`m`, `s`, `g`, `k`, `b`).
- A scope prefix (`m` member, `s` static, `g` global) is followed by `_`,
  because the name after it starts in lowercase. A type or kind prefix is
  glued to a capital letter: `ESeverity`, `kMaxLights`, `bVisible`.
- Prefixes combine, scope first: `m_bDirty`.
- The fixed-size aliases of `<aether/core/types.hpp>` (`i32`, `u8`, `f32`,
  `usize`) are lowercase on purpose, like built-in types.

clang-tidy (`readability-identifier-naming` in `.clang-tidy`) checks every
rule except the boolean one, which is left to review.
