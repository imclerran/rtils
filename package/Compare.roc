module [str, str, str_reverse]

num_to_comparator : Num a -> [LT, EQ, GT]
num_to_comparator = |n| if n < 0 then LT else if n > 0 then GT else EQ

str : Str, Str -> [LT, EQ, GT]
str = |a, b|
    if a == b then
        EQ
    else
        bytes_a = Str.to_utf8(a)
        bytes_b = Str.to_utf8(b)
        comp_list = List.map2(
            bytes_a,
            bytes_b,
            |byte_a, byte_b|
                if byte_a < byte_b then LT else if byte_a > byte_b then GT else EQ,
        )
        (List.find_first(comp_list, |comp| comp != EQ))
        |> Result.with_default((Num.to_i64(List.len(bytes_a)) - Num.to_i64(List.len(bytes_b)) |> num_to_comparator))

expect str("a", "b") == LT
expect str("b", "a") == GT
expect str("a", "a") == EQ
expect str("a", "aa") == LT
expect str("aa", "a") == GT
expect str("A", "a") == LT
expect str("a", "A") == GT
expect str("a", "Aa") == GT
expect str("Aa", "a") == LT

str_reverse : Str, Str -> [LT, EQ, GT]
str_reverse = |a, b| str(b, a)
