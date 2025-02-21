module [split_if, split_at_indices, split_with_delims, split_with_delims_head, split_with_delims_tail]

## Split a list into sublists using a predicate function to identify delimiters.
## ```
## expect [0, 1, 2, 3, 4] |> split_if(|x| x % 2 == 0) == [[1], [3]]
## ```
split_if : List a, (a -> Bool) -> List (List a)
split_if = |list, predicate|
    List.walk(
        list,
        { acc: [], current: [] },
        |{ acc, current }, item|
            if predicate(item) then
                if !List.is_empty(current) then
                    { acc: List.append(acc, current), current: [] }
                else
                    { acc, current }
            else
                { acc, current: List.append(current, item) },
    )
    |> |{ acc, current }| if !List.is_empty(current) then List.append(acc, current) else acc

expect
    split = [] |> split_if(|x| x == 0)
    split == []

expect
    split = [0] |> split_if(|x| x == 0)
    split == []

expect
    split = [1, 2, 3] |> split_if(|x| x == 0)
    split == [[1, 2, 3]]

expect
    split = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34] |> split_if(|x| x % 2 == 0)
    split == [[1, 1], [3, 5], [13, 21]]

split_first_if : List a, (a -> Bool) -> Result { before: List a, after: List a } [NotFound]
split_first_if = |list, predicate|
    index = List.find_first_index(list, predicate)?
    { before, others } = List.split_at(list, index)
    Ok({ before, after: List.drop_first(others, 1) })

expect [0, 1] |> split_first_if(|x| x % 2 == 1) == Ok({ before: [0], after: [] })
expect [0, 1] |> split_first_if(|x| x % 2 == 0) == Ok({ before: [], after: [1] })
expect [0, 1, 2, 3, 4] |> split_first_if(|x| x % 2 == 1) == Ok({ before: [0], after: [2, 3, 4] })
expect [0] |> split_first_if(|x| x % 2 == 1) == Err(NotFound)

split_last_if : List a, (a -> Bool) -> Result { before: List a, after: List a } [NotFound]
split_last_if = |list, predicate|
    index = List.find_last_index(list, predicate)?
    { before, others } = List.split_at(list, index)
    Ok({ before, after: List.drop_first(others, 1) })

expect [0, 1] |> split_last_if(|x| x % 2 == 1) == Ok({ before: [0], after: [] })
expect [0, 1] |> split_last_if(|x| x % 2 == 0) == Ok({ before: [], after: [1] })
expect [0, 1, 2, 3, 4] |> split_last_if(|x| x % 2 == 1) == Ok({ before: [0, 1, 2], after: [4] })
expect [0] |> split_last_if(|x| x % 2 == 1) == Err(NotFound)

split_at_indices : List a, List U64 -> List (List a)
split_at_indices = |list, indices|
    if List.is_empty(list) then
        [[]]
    else
        split_at_indices_help(list, List.sort_desc(indices))

split_at_indices_help : List a, List U64 -> List (List a)
split_at_indices_help = |list, indices|
    when indices is
        [x, .. as xs] if x != 0 and x != List.len(list) ->
            { before, others } = List.split_at(list, Num.to_u64(x))
            split_at_indices_help(before, xs) |> List.append(others)

        [_, .. as xs] ->
            split_at_indices_help(list, xs)

        [] -> [list]

expect [] |> split_at_indices([]) == [[]]
expect [] |> split_at_indices([0]) == [[]]
expect [0] |> split_at_indices([]) == [[0]]
expect [0] |> split_at_indices([0]) == [[0]]
expect [0] |> split_at_indices([1]) == [[0]]
expect [0, 1] |> split_at_indices([]) == [[0, 1]]
expect [0, 1] |> split_at_indices([0]) == [[0, 1]]
expect [0, 1] |> split_at_indices([1]) == [[0], [1]]
expect [0, 1] |> split_at_indices([2]) == [[0, 1]]
expect
    lists = [0, 1, 2, 3, 4, 5] |> split_at_indices([1, 3])
    lists == [[0], [1, 2], [3, 4, 5]]

## Split a list into sublists and include the delimiters in as single element sublists.
## ```
## expect [0, 1, 0, 0] |> split_with_delims(|x| x == 1) == [[0], [1], [0, 0]]
## ```
split_with_delims : List a, (a -> Bool) -> List (List a)
split_with_delims = |list, predicate|
    is_delimiter = |v| if predicate(v) then Delim else NotDelim
    drop_trailing_empty = |lists|
        when lists is
            [.. as xs, []] -> xs
            _ -> lists
    List.walk(
        list,
        [],
        |lists, value|
            when lists is
                [.. as sublists, []] ->
                    when is_delimiter(value) is
                        Delim -> List.join([sublists, [[value]], [[]]])
                        NotDelim -> List.append(sublists, [value])

                [.. as sublists, sublist] ->
                    when is_delimiter(value) is
                        Delim -> List.join([sublists, [sublist], [[value]], [[]]])
                        NotDelim -> List.join([sublists, [List.append(sublist, value)]])

                [] ->
                    when is_delimiter(value) is
                        Delim -> [[value], []]
                        NotDelim -> [[value]],
    )
    |> drop_trailing_empty

expect [] |> split_with_delims(|x| x == 1) == []
expect [0] |> split_with_delims(|x| x == 1) == [[0]]
expect [1] |> split_with_delims(|x| x == 1) == [[1]]
expect [0, 1] |> split_with_delims(|x| x == 1) == [[0], [1]]
expect [1, 0] |> split_with_delims(|x| x == 1) == [[1], [0]]
expect
    lists = [0, 1, 0, 0, 1, 0, 0, 0] |> split_with_delims(|x| x == 1)
    lists == [[0], [1], [0, 0], [1], [0, 0, 0]]
expect 
    lists = split_with_delims(['0', '1', '2', '3', '4'], |c| List.contains(['0', '1'], c)) 
    lists == [['0'], ['1'], ['2', '3', '4']]

## Split a list into sublists and include the delimiters at the head of each sublist.
## ```
## expect [0, 1, 0, 0] |> split_with_delims_head(|x| x == 1) == [[0], [1, 0, 0]]
## ```
split_with_delims_head : List a, (a -> Bool) -> List (List a)
split_with_delims_head = |list, predicate|
    is_delimiter = |v| if predicate(v) then Delim else NotDelim
    List.walk(
        list,
        [],
        |lists, value|
            when lists is
                [.. as sublists, sublist] ->
                    when is_delimiter(value) is
                        Delim -> List.join([sublists, [sublist], [[value]]])
                        NotDelim -> List.join([sublists, [List.append(sublist, value)]])

                [] -> [[value]],
    )

expect [] |> split_with_delims_head(|x| x == 1) == []
expect [0] |> split_with_delims_head(|x| x == 1) == [[0]]
expect [1] |> split_with_delims_head(|x| x == 1) == [[1]]
expect [0, 1] |> split_with_delims_head(|x| x == 1) == [[0], [1]]
expect [1, 0] |> split_with_delims_head(|x| x == 1) == [[1, 0]]
expect
    lists = [0, 1, 0, 0, 1, 0, 0, 0] |> split_with_delims_head(|x| x == 1)
    lists == [[0], [1, 0, 0], [1, 0, 0, 0]]

## Split a list into sublists and include the delimiters at the tail of each sublist.
## ```
## expect [0, 1, 0, 0] |> split_with_delims_tail(|x| x == 1) == [[0, 1], [0, 0]]
## ```
split_with_delims_tail : List a, (a -> Bool) -> List (List a)
split_with_delims_tail = |list, predicate|
    delimit = |v| if predicate(v) then Delim else NotDelim
    List.walk(
        list,
        [],
        |lists, value|
            when lists is
                [.., []] ->
                    crash "Last sublist will never be empty"

                [.. as sublists, [.. as sublist, last_value]] ->
                    when delimit(last_value) is
                        Delim ->
                            List.join([sublists, [List.append(sublist, last_value)], [[value]]])

                        NotDelim ->
                            List.append(sublists, List.join([sublist, [last_value], [value]]))

                [] -> [[value]],
    )

expect [] |> split_with_delims_tail(|x| x == 1) == []
expect [0] |> split_with_delims_tail(|x| x == 1) == [[0]]
expect [1] |> split_with_delims_tail(|x| x == 1) == [[1]]
expect [0, 1] |> split_with_delims_tail(|x| x == 1) == [[0, 1]]
expect [1, 0] |> split_with_delims_tail(|x| x == 1) == [[1], [0]]
expect
    lists = [0, 1, 0, 0, 1, 0, 0, 0] |> split_with_delims_tail(|x| x == 1)
    lists == [[0, 1], [0, 0, 1], [0, 0, 0]]
