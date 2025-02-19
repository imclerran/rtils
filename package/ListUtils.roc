module [split_if]

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
