module [split_first_if, split_last_if, capitalize, lowercase, uppercase, pad_left, pad_right, pad_left_ascii, pad_right_ascii]

import ListUtils

split_first_if : Str, (U8 -> Bool) -> Result { before: Str, after: Str } [NotFound]
split_first_if = |str, predicate|
    Str.to_utf8(str) 
    |> ListUtils.split_first_if(predicate) 
    |> Result.map_ok(|{ before, after }| { before: Str.from_utf8_lossy(before), after: Str.from_utf8_lossy(after) })

expect "0100010" |> split_first_if(|c| c == '1') == Ok({ before: "0", after: "00010" })
expect "0100010" |> split_first_if(|c| c == '0') == Ok({ before: "", after: "100010" })
expect "0100010" |> split_first_if(|c| c == '2') == Err(NotFound)

split_last_if : Str, (U8 -> Bool) -> Result { before: Str, after: Str } [NotFound]
split_last_if = |str, predicate|
    Str.to_utf8(str) 
    |> ListUtils.split_last_if(predicate) 
    |> Result.map_ok(|{ before, after }| { before: Str.from_utf8_lossy(before), after: Str.from_utf8_lossy(after) })

expect "0100010" |> split_last_if(|c| c == '1') == Ok({ before: "01000", after: "0" })
expect "0100010" |> split_last_if(|c| c == '0') == Ok({ before: "010001", after: "" })
expect "0100010" |> split_last_if(|c| c == '2') == Err(NotFound)

## If the first character of the string is a lowercase letter, capitalize it. Lowercase the rest of the string.
capitalize : Str -> Str
capitalize = |str| Str.to_utf8(str) |> capitalize_help |> Str.from_utf8_lossy

capitalize_help : List U8 -> List U8
capitalize_help = |bytes|
    when bytes is
        [first, .. as rest] ->
            if is_lowercase(first) then
                List.join([[first - 32], lowercase_help(rest)])
            else
                List.join([[first], lowercase_help(rest)])

        [] -> []

## Convert all ASCII letters in the string to uppercase.
uppercase : Str -> Str
uppercase = |str| Str.to_utf8(str) |> uppercase_help |> Str.from_utf8_lossy

uppercase_help : List U8 -> List U8
uppercase_help = |bytes|
    when bytes is
        [first, .. as rest] ->
            if is_lowercase(first) then
                List.join([[first - 32], uppercase_help(rest)])
            else
                List.join([[first], uppercase_help(rest)])

        [] -> []

lowercase : Str -> Str
lowercase = |str| Str.to_utf8(str) |> lowercase_help |> Str.from_utf8_lossy

## Convert all ASCII letters in the string to lowercase.
lowercase_help : List U8 -> List U8
lowercase_help = |bytes|
    when bytes is
        [first, .. as rest] ->
            if is_uppercase(first) then
                List.join([[first + 32], lowercase_help(rest)])
            else
                List.join([[first], lowercase_help(rest)])

        [] -> []

is_lowercase = |c| c >= 'a' and c <= 'z'

is_uppercase = |c| c >= 'A' and c <= 'Z'

is_printed_ascii_char = |c| c >= 32 and c <= 126

is_printed_ascii : Str -> Bool
is_printed_ascii = |str| Str.to_utf8(str) |> List.all(is_printed_ascii_char)

## Pad the string with the given character on the left until it reaches the target length. Returns an Error if the string contains characters that are not printable ASCII. If the padding character is not printable ASCII, it will be replaced with a space.
## ```
## expect pad_left("123", '_', 5) == Ok("__123")
## expect pad_left("123", 127, 5) == Ok("  123")
## expect pad_left("🔥", ' ', 2) == Err(InvalidASCII)
## ```
pad_left : Str, U8, U64 -> Result Str [InvalidASCII]
pad_left = |str, char, target_length|
    if is_printed_ascii(str) then
        Ok(pad_left_ascii(str, char, target_length))
    else
        Err(InvalidASCII)

expect pad_left("123", ' ', 5) == Ok("  123")
expect pad_left("🔥", ' ', 2) == Err(InvalidASCII)
expect pad_left([1] |> Str.from_utf8_lossy, ' ', 2) == Err(InvalidASCII)

## Pad the string with the given character on the right until it reaches the target length. Returns an Error if the string contains characters that are not printable ASCII. If the padding character is not printable ASCII, it will be replaced with a space.
## ```
## expect pad_right("123", '_', 5) == Ok("123__")
## expect pad_right("123", 127, 5) == Ok("123  ")
## expect pad_right("🔥", ' ', 2) == Err(InvalidASCII)
## ```
pad_right : Str, U8, U64 -> Result Str [InvalidASCII]
pad_right = |str, char, target_length|
    if is_printed_ascii(str) then
        Ok(pad_right_ascii(str, char, target_length))
    else
        Err(InvalidASCII)

expect pad_right("123", ' ', 5) == Ok("123  ")
expect pad_right("🔥", ' ', 2) == Err(InvalidASCII)
expect pad_left([1] |> Str.from_utf8_lossy, ' ', 2) == Err(InvalidASCII)

## Pad the string with the given character on the left until it reaches the target length. May result in undefined behavior for strings containing characters besides printable ASCII. If the padding character is not printable ASCII, it will be replaced with a space.
## ```
## expect pad_left_ascii("123", ' ', 5) == "  123"
## expect pad_left_ascii("123", 127, 5) == "  123"
## expect pad_left_ascii("🔥", ' ', 2) == "🔥"
## ```
pad_left_ascii : Str, U8, U64 -> Str
pad_left_ascii = |str, char, target_length|
    bytes = Str.to_utf8(str)
    cur_len = List.len(bytes)
    pad_len = if target_length > cur_len then target_length - cur_len else 0
    pad_char = if is_printed_ascii_char(char) then char else ' '
    pad = List.repeat(pad_char, pad_len)
    Str.from_utf8_lossy(List.join [pad, bytes])

expect pad_left_ascii("123", ' ', 5) == "  123"
expect pad_left_ascii("123", ' ', 2) == "123"
expect pad_left_ascii("123", 127, 5) == "  123"
expect pad_left_ascii("123", '_', 5) == "__123"
expect pad_left_ascii("🔥", ' ', 2) == "🔥"

## Pad the string with the given character on the right until it reaches the target length. May result in undefined behavior for strings containing characters besides printable ASCII. If the padding character is not printable ASCII, it will be replaced with a space.
## ```
## expect pad_right_ascii("123", ' ', 5) == "123  "
## expect pad_right_ascii("123", 127, 5) == "123  "
## expect pad_right_ascii("🔥", ' ', 2) == "🔥"
## ```
pad_right_ascii : Str, U8, U64 -> Str
pad_right_ascii = |str, char, target_length|
    bytes = Str.to_utf8(str)
    cur_len = List.len(bytes)
    pad_len = if target_length > cur_len then target_length - cur_len else 0
    pad_char = if is_printed_ascii_char(char) then char else ' '
    pad = List.repeat(pad_char, pad_len)
    Str.from_utf8_lossy(List.join [bytes, pad])

expect pad_right_ascii("123", ' ', 5) == "123  "
expect pad_right_ascii("123", ' ', 2) == "123"
expect pad_right_ascii("123", 127, 5) == "123  "
expect pad_right_ascii("123", '_', 5) == "123__"
expect pad_right_ascii("🔥", ' ', 2) == "🔥"

# Removed due to https://github.com/roc-lang/roc/issues/7583
# import unicode.Grapheme

# pad_left_unicode : Str, Str, U64 -> Str
# pad_left_unicode = |str, char, target_length|
#     chars = Grapheme.split(str) |> Result.with_default([])
#     cur_len = List.len(chars)
#     pad_len = if target_length > cur_len then target_length - cur_len else 0
#     pad_char = if Grapheme.split(char) |> Result.with_default([]) == [char] then char else " "
#     pad = Str.repeat(pad_char, pad_len)
#     "${pad}${str}"

# expect pad_left_unicode("123", " ", 5) == "  123"
# expect pad_left_unicode("🧑‍🧑‍🧒‍🧒", " ", 2) == " 🧑‍🧑‍🧒‍🧒"
# expect pad_left_unicode(" family", "🧑‍🧑‍🧒‍🧒", 8) == "🧑‍🧑‍🧒‍🧒 family"
# expect pad_left_unicode("345", "12", 5) == "  345"

# pad_right_unicode : Str, Str, U64 -> Str
# pad_right_unicode = |str, char, target_length|
#     chars = Grapheme.split(str) |> Result.with_default([])
#     cur_len = List.len(chars)
#     pad_len = if target_length > cur_len then target_length - cur_len else 0
#     pad_char = if Grapheme.split(char) |> Result.with_default([]) == [char] then char else " "
#     pad = Str.repeat(pad_char, pad_len)
#     "${str}${pad}"

# expect pad_right_unicode("123", " ", 5) == "123  "
# expect pad_right_unicode("🧑‍🧑‍🧒‍🧒", " ", 2) == "🧑‍🧑‍🧒‍🧒 "
# expect pad_right_unicode("family ", "🧑‍🧑‍🧒‍🧒", 8) == "family 🧑‍🧑‍🧒‍🧒"
# expect pad_right_unicode("345", "12", 5) == "345  "

