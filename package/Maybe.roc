module [Maybe, map, with_default, map_with_default, from_result]

## A type that represents a value that may or may not be present.
Maybe a : [Some a, None]

## Apply a transformation to the value of a Maybe.
## ```
## expect Some(1) |> map(Number) == Some(Number(1))
## expect None |> map(Number) == None
## ```
map : Maybe a, (a -> b) -> Maybe b
map = |maybe, transform|
    when maybe is
        Some(v) -> Some(transform(v))
        None -> None

## Return the value of a Maybe or the default if None.
## ```
## expect Some(1) |> with_default(0) == 1
## expect None |> with_default(0) == 0
## ```
with_default : Maybe a, a -> a
with_default = |maybe, default|
    when maybe is
        Some(v) -> v
        None -> default

## Transform a Maybe value or return the default if None.
## ```
## expect Some(1) |> map_with_default(Number, Nothing) == Number(1)
## expect None |> map_with_default(Number, Nothing) == Nothing
## ```
map_with_default : Maybe a, (a -> b), b -> b
map_with_default = |m, f, g|
    when m is
        Some(v) -> f(v)
        None -> g

from_result : Result a err -> Maybe a
from_result = |result|
    when result is
        Ok(v) -> Some(v)
        Err(_) -> None
