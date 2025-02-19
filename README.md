# rtils
A collection of commonly used functions and types for Roc.

[![Roc-Lang][roc_badge]][roc_link]
[![GitHub last commit][last_commit_badge]][last_commit_link]
[![CI status][ci_status_badge]][ci_status_link]
[![Latest release][version_badge]][version_link]

## Modules:

__ListUtils__
- split_if : List a, (a -> Bool) -> List (List a)

__Maybe__
- Maybe a : [Some a, None]
- map : Maybe a, (a -> b) -> Maybe b
- with_default : Maybe a, a -> a
- map_with_default : Maybe a, (a -> b), b -> b

__StrUtils__
- capitalize : Str -> Str
- lowercase : Str -> Str
- uppercase : Str -> Str

__Unsafe__
- unwrap : Result a err -> a

<!-- LINKS -->
[roc_badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fpastebin.com%2Fraw%2FcFzuCCd7
[roc_link]: https://github.com/roc-lang/roc
[ci_status_badge]: https://img.shields.io/github/actions/workflow/status/imclerran/rtils/ci.yaml?logo=github&logoColor=lightgrey
[ci_status_link]: https://github.com/imclerran/rtils/actions/workflows/ci.yaml
[last_commit_badge]: https://img.shields.io/github/last-commit/imclerran/rtils?logo=git&logoColor=lightgrey
[last_commit_link]: https://github.com/imclerran/rtils/commits/main/
[version_badge]: https://img.shields.io/github/v/release/imclerran/rtils
[version_link]: https://github.com/imclerran/rtils/releases/latest

