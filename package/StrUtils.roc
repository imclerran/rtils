module [capitalize, lowercase, uppercase]

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