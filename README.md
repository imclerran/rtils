# rtils
A collection of commonly used functions and types for Roc.

[![Roc-Lang][roc_badge]][roc_link]
[![GitHub last commit][last_commit_badge]][last_commit_link]
[![CI status][ci_status_badge]][ci_status_link]
[![Latest release][version_badge]][version_link]

## Modules:

__Compare__
```roc
num_asc : number, number -> [LT, EQ, GT]
num_desc : number, number -> [LT, EQ, GT]
str_asc : Str, Str -> [LT, EQ, GT]
str_desc : Str, Str -> [LT, EQ, GT]
```

__ListUtils__
```roc
map2 : List(a), List(b), (a, b -> c) -> List(c)
zip : List(a), List(b) -> List((a, b))
find_first : List(a), (a -> Bool) -> Try(a, [NotFound])
find_last : List(a), (a -> Bool) -> Try(a, [NotFound])
find_first_index : List(a), (a -> Bool) -> Try(U64, [NotFound])
find_last_index : List(a), (a -> Bool) -> Try(U64, [NotFound])
split_at : List(a), U64 -> { before : List(a), others : List(a) }
split_on : List(a), a -> List(List(a))
split_on_list : List(a), List(a) -> List(List(a))
split_if : List(a), (a -> Bool) -> List(List(a))
split_first : List(a), a -> Try({ before : List(a), after : List(a) }, [NotFound])
split_first_if : List(a), (a -> Bool) -> Try({ before : List(a), after : List(a) }, [NotFound])
split_last : List(a), a -> Try({ before : List(a), after : List(a) }, [NotFound])
split_last_if : List(a), (a -> Bool) -> Try({ before : List(a), after : List(a) }, [NotFound])
split_at_indices : List(a), List(U64) -> List(List(a))
split_with_delims : List(a), (a -> Bool) -> List(List(a))
split_with_delims_head : List(a), (a -> Bool) -> List(List(a))
split_with_delims_tail : List(a), (a -> Bool) -> List(List(a))
```

__Maybe__
```roc
Maybe(a) : [Some(a), None]
some : a -> Maybe(a)
none : Maybe(_)
is_eq : Maybe(a), Maybe(a) -> Bool
map : Maybe(a), (a -> b) -> Maybe(b)
with_default : Maybe(a), a -> a
from_try : Try(a, err) -> Maybe(a)
```

__NumUtils__
```roc
is_approx_eq : F64, F64 -> Bool
is_approx_eq_to_places : F64, F64, U64 -> Bool
```

__StrUtils__
```roc
split_if : Str, (U8 -> Bool) -> List(Str)
split_first_if : Str, (U8 -> Bool) -> Try({ before : Str, after : Str }, [NotFound])
split_last_if : Str, (U8 -> Bool) -> Try({ before : Str, after : Str }, [NotFound])
capitalize : Str -> Str
lowercase : Str -> Str
uppercase : Str -> Str
pad_left : Str, U8, U64 -> Try(Str, [InvalidASCII])
pad_right : Str, U8, U64 -> Try(Str, [InvalidASCII])
```

__Unsafe__
```roc
unwrap : Try(a, err) -> a
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

