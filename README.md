# rtils
A collection of commonly used functions and types for Roc.

[![Roc-Lang][roc_badge]][roc_link]
[![GitHub last commit][last_commit_badge]][last_commit_link]
[![CI status][ci_status_badge]][ci_status_link]
[![Latest release][version_badge]][version_link]

## Contents:

Module    | Exposed
----------|-------------------------------------------------
ListUtils | split_if : List a, (a -> Bool) -> List (List a)
Maybe     | Maybe a : [Some a, None]
Maybe     | map : Maybe a, (a -> b) -> Maybe b
Maybe     | with_default : Maybe a, a -> a
Maybe     | map_with_default : Maybe a, (a -> b), b -> b
StrUtils  | capitalize : Str -> Str
StrUtils  | lowercase : Str -> Str
StrUtils  | uppercase : Str -> Str
Unsafe    | unwrap : Result a err -> a

<!-- LINKS -->
[roc_badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fpastebin.com%2Fraw%2FcFzuCCd7
[roc_link]: https://github.com/roc-lang/roc
[ci_status_badge]: https://img.shields.io/github/actions/workflow/status/imclerran/rtils/ci.yaml?logo=github&logoColor=lightgrey
[ci_status_link]: https://github.com/imclerran/rtils/actions/workflows/ci.yaml
[last_commit_badge]: https://img.shields.io/github/last-commit/imclerran/rtils?logo=git&logoColor=lightgrey
[last_commit_link]: https://github.com/imclerran/rtils/commits/main/
[version_badge]: https://img.shields.io/github/v/release/imclerran/rtils
[version_link]: https://github.com/imclerran/rtils/releases/latest

