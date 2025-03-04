# rtils
A collection of commonly used functions and types for Roc.

[![Roc-Lang][roc_badge]][roc_link]
[![GitHub last commit][last_commit_badge]][last_commit_link]
[![CI status][ci_status_badge]][ci_status_link]
[![Latest release][version_badge]][version_link]

## Modules:

__Compare__
```roc
str : Str, Str -> [LT, EQ, GT]
str_reverse : Str, Str -> [LT, EQ, GT]
```

__ListUtils__
```roc
split_if : List a, (a -> Bool) -> List (List a)
split_first_if : List a, (a -> Bool) -> Result { before: List a, after: List a } [NotFound]
split_last_if : List a, (a -> Bool) -> Result { before: List a, after: List a } [NotFound]
split_at_indices : List a, List U64 -> List (List a)
split_with_delims : List a, (a -> Bool) -> List (List a)
split_with_delims_head : List a, (a -> Bool) -> List (List a)
split_with_delims_tail : List a, (a -> Bool) -> List (List a)
```

__Maybe__
```roc
Maybe a : [Some a, None]
map : Maybe a, (a -> b) -> Maybe b
with_default : Maybe a, a -> a
map_with_default : Maybe a, (a -> b), b -> b
from_result : Result a err -> Maybe a
```

__NumUtils__
```roc
approx_eq : Frac a, Frac a -> Bool
approx_eq_out_to : Frac a, Frac a, Num b -> Bool
```

__StrUtils__
```roc
split_if : Str, (U8 -> Bool) -> List Str
split_first_if : Str, (U8 -> Bool) -> Result { before: Str, after: Str } [NotFound]
split_last_if : Str, (U8 -> Bool) -> Result { before: Str, after: Str } [NotFound]
capitalize : Str -> Str
lowercase : Str -> Str
uppercase : Str -> Str
pad_left : Str, U8, U64 -> Result Str [InvalidASCII]
pad_right : Str, U8, U64 -> Result Str [InvalidASCII]
pad_left_ascii : Str, U8, U64 -> Str
pad_right_ascii : Str, U8, U64 -> Str
```

__Unsafe__
```roc
unwrap : Result a err, Str -> a
```

<!-- LINKS -->
[roc_badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fpastebin.com%2Fraw%2FcFzuCCd7
[roc_link]: https://github.com/roc-lang/roc
[ci_status_badge]: https://img.shields.io/github/actions/workflow/status/imclerran/rtils/ci.yaml?logo=github&logoColor=lightgrey
[ci_status_link]: https://github.com/imclerran/rtils/actions/workflows/ci.yaml
[last_commit_badge]: https://img.shields.io/github/last-commit/imclerran/rtils?logo=git&logoColor=lightgrey
[last_commit_link]: https://github.com/imclerran/rtils/commits/main/
[version_badge]: https://img.shields.io/github/v/release/imclerran/rtils
[version_link]: https://github.com/imclerran/rtils/releases/latest

