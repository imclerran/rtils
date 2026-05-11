ListUtils :: [].{

	## Apply a binary function to pairs of elements from two lists, returning a list of results.
	## ```
	## expect [1, 2, 3]->map2([10, 20, 30], I64.plus) == [11, 22, 33]
	## ```
	map2 : List(a), List(b), (a, b -> c) -> List(c)
	map2 = |a_list, b_list, transform| {
		var $result = []
		var $index = 0
		while ($index < a_list.len() and $index < b_list.len()) {
			match (a_list.get($index), b_list.get($index)) {
				(Ok(a), Ok(b)) => {
					$result = $result.append(transform(a, b))
				}
				_ => {
					break
				}
			}
			$index = $index + 1
		}
		$result
	}

	## Create a list of pairs by combining elements from two lists at corresponding positions.
	## ```
	## expect [1, 2, 3]->zip(["a", "b", "c"]) == [(1, "a"), (2, "b"), (3, "c")]
	## ```
	zip : List(a), List(b) -> List((a, b))
	zip = |a_list, b_list| map2(a_list, b_list, |a, b| (a, b))

	## Find the first element in a list that satisfies a given predicate, returning it wrapped in `Ok` if found, or `Err(NotFound)` if no such element exists.
	## ```
	## expect [1, 2, 3, 4]->find_first(|x| x % 2 == 0) == Ok(2)
	## ```
	find_first : List(a), (a -> Bool) -> Try(a, [NotFound])
	find_first = |list, predicate| {
		for item in list if predicate(item) {
			return Ok(item)
		}
		return Err(NotFound)
	}

	## Find the last element in a list that satisfies a given predicate, returning it wrapped in `Ok` if found, or `Err(NotFound)` if no such element exists.
	## ```
	## expect [1, 2, 3, 4]->find_last(|x| x % 2 == 0) == Ok(4)
	## ```
	find_last : List(a), (a -> Bool) -> Try(a, [NotFound])
	find_last = |list, predicate| {
		for item in list.rev() if predicate(item) {
			return Ok(item)
		}
		return Err(NotFound)
	}

	## Find the index of the first element in a list that satisfies a given predicate, returning it wrapped in `Ok` if found, or `Err(NotFound)` if no such element exists.
	## ```
	## expect [1, 2, 3, 4]->find_first_index(|x| x > 1) == Ok(1)
	## ```
	find_first_index : List(a), (a -> Bool) -> Try(U64, [NotFound])
	find_first_index = |list, predicate| {
		var $idx = 0
		for item in list {
			if predicate(item) {
				return Ok($idx)
			}
			$idx = $idx + 1
		}
		return Err(NotFound)
	}

	## Find the index of the last element in a list that satisfies a given predicate, returning it wrapped in `Ok` if found, or `Err(NotFound)` if no such element exists.
	## ```
	## expect [1, 2, 3, 4]->find_last_index(|x| x < 4) == Ok(2)
	## ```
	find_last_indxex : List(a), (a -> Bool) -> Try(U64, [NotFound])
	find_last_index = |list, predicate| {
		var $idx = list.len()
		for item in list.rev() {
			$idx = $idx - 1
			if predicate(item) {
				return Ok($idx)
			}
		}
		return Err(NotFound)
	}

	## Split a list into two parts at a specified index, returning the part before the index and the part from the index onward.
	## ```
	## expect [0, 1, 2, 3, 4]->split_at(2) == { before: [0, 1], others: [2, 3, 4] }
	## ```
	split_at : List(a), U64 -> { before : List(a), others : List(a) }
	split_at = |list, idx| {
		before = list.sublist({ start: 0, len: idx })
		len = list.len()
		others = list.sublist({ start: idx, len: len - idx })
		{ before, others }
	}

	## Split a list into sublists using a specified delimiter element.
	## ```
	## expect [1, 2, 1, 2, 3]->split_on(1) == [[2], [2, 3]]
	## ```
	split_on : List(a), a -> List(List(a)) where [a.is_eq : a, a -> Bool]
	split_on = |list, delim| list->split_if(|x| x == delim)

	## Split a list into sublists using a specified delimiter list.
	## ```
	## expect [1, 2, 3, 4, 5]->split_on_list([2, 3]) == [[1], [4, 5]]
	## ```
	split_on_list : List(a), List(a) -> List(List(a))
		where [a.is_eq : a, a -> Bool]
	split_on_list = |list, delim_l| {
		if delim_l.is_empty() {
			return [list]
		}

		delim_len = delim_l.len()
		list_len = list.len()
		var $lists = []
		var $current = []
		var $skip = 0
		var $i = 0

		for elem in list {
			if $skip > 0 {
				$skip = $skip - 1
			} else if $i + delim_len <= list_len
				and list.sublist({ start: $i, len: delim_len }) == delim_l {
				$lists = $lists.append($current)
				$current = []
				$skip = delim_len - 1
			} else {
				$current = $current.append(elem)
			}
			$i = $i + 1
		}

		$lists.append($current) # ← unconditional
	}

	## Split a list into sublists using a predicate function to identify delimiters.
	## ```
	## expect [0, 1, 2, 3, 4]->split_if(|x| x % 2 == 0) == [[1], [3]]
	## ```
	split_if : List(a), (a -> Bool) -> List(List(a))
	split_if = |list, predicate| {
		var $acc = []
		var $current = []

		for item in list {
			if predicate(item) {
				if !$current.is_empty() {
					$acc = $acc.append($current)
					$current = []
				}
			} else {
				$current = $current.append(item)
			}
		}
		if !$current.is_empty() $acc.append($current) else $acc
	}

	## Split a list into two parts at the first occurrence of a specified delimiter element, returning the part before the delimiter and the part after it. If the delimiter is not found, return `Err(NotFound)`.
	## ```
	## expect [0, 1, 2, 1, 2]->split_first(2) == Ok({ before: [0, 1], after: [1, 2] })
	## ```
	split_first : List(a), a -> Try({ before : List(a), after : List(a) }, [NotFound])
		where [a.is_eq : a, a -> Bool]
	split_first = |list, delim| list->split_first_if(|elem| elem == delim)

	## Split a list into two parts at the first occurrence of an element that satisfies a given predicate, returning the part before the element and the part after it. If no such element is found, return `Err(NotFound)`.
	## ```
	## expect [0, 1, 2, 3, 4]->split_first_if(|x| x >= 2) == Ok({ before: [0, 1], after: [3, 4] })
	## ```
	split_first_if : List(a), (a -> Bool) -> Try({ before : List(a), after : List(a) }, [NotFound])
	split_first_if = |list, predicate| {
		index = list->find_first_index(predicate)?
		{ before, others } = list->split_at(index)
		Ok({ before, after: others.drop_first(1) })
	}

	## Split a list into two parts at the last occurrence of a specified delimiter element, returning the part before the delimiter and the part after it. If the delimiter is not found, return `Err(NotFound)`.
	## ```
	## expect [0, 1, 2, 1, 2]->split_last(1) == Ok({ before: [0, 1, 2], after: [2] })
	## ```
	split_last : List(a), a -> Try({ before : List(a), after : List(a) }, [NotFound])
		where [a.is_eq : a, a -> Bool]
	split_last = |list, delim| list->split_last_if(|elem| elem == delim)

	## Split a list into two parts at the last occurrence of an element that satisfies a given predicate, returning the part before the element and the part after it. If no such element is found, return `Err(NotFound)`.
	## ```
	## expect [0, 1, 2, 3, 4]->split_last_if(|x| x >= 2) == Ok({ before: [0, 1, 2, 3], after: [] })
	## ```
	split_last_if : List(a), (a -> Bool) -> Try({ before : List(a), after : List(a) }, [NotFound])
	split_last_if = |list, predicate| {
		index = list->find_last_index(predicate)?
		{ before, others } = list->split_at(index)
		Ok({ before, after: others.drop_first(1) })
	}

	## Split a list into sublists at specified indices.
	## ```
	## expect [0, 1, 2, 3, 4, 5]->split_at_indices([1, 3]) == [[0], [1, 2], [3, 4, 5]]
	## ```
	split_at_indices : List(a), List(U64) -> List(List(a))
	split_at_indices = |list, indices| {
		if list.is_empty() {
			return [[]]
		}
		list_len = list.len()
		var $result = []
		var $current = []
		var $i = 0
		for elem in list {
			if $i > 0 and $i < list_len and indices.contains($i) {
				$result = $result.append($current)
				$current = []
			}
			$current = $current.append(elem)
			$i = $i + 1
		}
		$result.append($current)
	}

	## Split a list into sublists and include the delimiters in as single element sublists.
	## ```
	## expect [0, 1, 0, 0]->split_with_delims(|x| x == 1) == [[0], [1], [0, 0]]
	## ```
	split_with_delims : List(a), (a -> Bool) -> List(List(a))
	split_with_delims = |list, predicate| {
		var $result = []
		var $current = []

		for value in list {
			if predicate(value) {
				# delimiter: flush in-progress chunk (if any), then emit [value]
				if !$current.is_empty() {
					$result = $result.append($current)
					$current = []
				}
				$result = $result.append([value])
			} else {
				$current = $current.append(value)
			}
		}

		if !$current.is_empty() {
			$result = $result.append($current)
		}
		$result
	}

	## Split a list into sublists and include the delimiters at the head of each sublist.
	## ```
	## expect [0, 1, 0, 0]->split_with_delims_head(|x| x == 1) == [[0], [1, 0, 0]]
	## ```
	split_with_delims_head : List(a), (a -> Bool) -> List(List(a))
	split_with_delims_head = |list, predicate|
		list.fold(
			[],
			|lists, value|
				match lists {
					[.. as sublists, sublist] =>
						if predicate(value) {
							sublists.append(sublist).append([value])
						} else {
							sublists.append(sublist.append(value))
						}

					[] => [[value]]
				},
		)

	## Split a list into sublists and include the delimiters at the tail of each sublist.
	## ```
	## expect [0, 1, 0, 0]->split_with_delims_tail(|x| x == 1) == [[0, 1], [0, 0]]
	## ```
	split_with_delims_tail : List(a), (a -> Bool) -> List(List(a))
	split_with_delims_tail = |list, predicate|
		list.fold(
			[],
			|lists, value|
				match lists {
					[.. as sublists, [.. as sublist, last_value]] =>
						if predicate(last_value) {
							sublists.append(sublist.append(last_value)).append([value])
						}
							else {
								sublists.append(sublist.append(last_value).append(value))
							}

					[] => [[value]]

					[.., []] => {
						crash "Sublist will never be empty"
					}
				},
		)
}

# ----- tests -----

# map2 tests
expect [1, 2, 3]->map2([10, 20, 30], I64.plus) == [11, 22, 33]
expect [1, 2, 3]->map2([10, 20], |a, b| a + b) == [11, 22]
expect [1]->map2([10, 20, 30], |a, b| a + b) == [11]
expect [1, 2, 3.U64]->map2(["a", "b", "c"], |n, s| "${n.to_str()}-${s}") == ["1-a", "2-b", "3-c"]

# zip tests
expect [1, 2, 3]->zip(["a", "b", "c"]) == [(1, "a"), (2, "b"), (3, "c")]
expect [1, 2, 3]->zip(["a", "b"]) == [(1, "a"), (2, "b")]
expect []->zip(["a", "b"]) == []
expect [1, 2]->zip([]) == []

# find_first_index tests
expect []->find_first_index(|x| x == 1) == Err(NotFound)
expect [0]->find_first_index(|x| x == 1) == Err(NotFound)
expect [1]->find_first_index(|x| x == 1) == Ok(0)
expect [1, 1]->find_first_index(|x| x == 1) == Ok(0)
expect [0, 1]->find_first_index(|x| x == 1) == Ok(1)

# find_last_index tests
expect []->find_last_index(|x| x == 1) == Err(NotFound)
expect [0]->find_last_index(|x| x == 1) == Err(NotFound)
expect [1]->find_last_index(|x| x == 1) == Ok(0)
expect [1, 1]->find_last_index(|x| x == 1) == Ok(1)
expect [1, 0]->find_last_index(|x| x == 1) == Ok(0)

# split_at tests
expect []->split_at(0) == { before: [], others: [] }
expect [0]->split_at(0) == { before: [], others: [0] }
expect [0]->split_at(1) == { before: [0], others: [] }
expect [0]->split_at(5) == { before: [0], others: [] }
expect [0, 1]->split_at(1) == { before: [0], others: [1] }
expect [0, 1, 2, 3, 4, 5]->split_at(0) == { before: [], others: [0, 1, 2, 3, 4, 5] }
expect [0, 1, 2, 3, 4, 5]->split_at(3) == { before: [0, 1, 2], others: [3, 4, 5] }
expect [0, 1, 2, 3, 4, 5]->split_at(5) == { before: [0, 1, 2, 3, 4], others: [5] }
expect [0, 1, 2, 3, 4, 5]->split_at(6) == { before: [0, 1, 2, 3, 4, 5], others: [] }

# split_on tests
expect []->split_on(0) == []
expect [0]->split_on(0) == []
expect [1, 2, 3]->split_on(0) == [[1, 2, 3]]
expect [0, 1, 1, 0, 3, 5, 0, 13, 21, 0]->split_on(0) == [[1, 1], [3, 5], [13, 21]]

# split_on_list tests
expect [1, 2, 3]->split_on_list([1, 2]) == [[], [3]]
expect [1, 1, 2]->split_on_list([1, 2]) == [[1], []]
expect [1, 1, 1, 2]->split_on_list([1, 2]) == [[1, 1], []]
expect [1, 2, 1, 2]->split_on_list([1, 2]) == [[], [], []]
expect ['a', 'a', 'a']->split_on_list(['a', 'a']) == [[], ['a']]

# split_if tests
expect []->split_if(|x| x == 0) == []
expect [0]->split_if(|x| x == 0) == []
expect [1, 2, 3]->split_if(|x| x == 0) == [[1, 2, 3]]
expect [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]->split_if(|x| x % 2 == 0) == [[1, 1], [3, 5], [13, 21]]

# split_first tests
expect [0, 1]->split_first(1) == Ok({ before: [0], after: [] })
expect [0, 1]->split_first(0) == Ok({ before: [], after: [1] })
expect [0, 1, 2, 1, 0]->split_first(1) == Ok({ before: [0], after: [2, 1, 0] })
expect [0]->split_first(1) == Err(NotFound)

# split_first_if tests
expect [0, 1]->split_first_if(|x| x % 2 == 1) == Ok({ before: [0], after: [] })
expect [0, 1]->split_first_if(|x| x % 2 == 0) == Ok({ before: [], after: [1] })
expect [0, 1, 2, 3, 4]->split_first_if(|x| x % 2 == 1) == Ok({ before: [0], after: [2, 3, 4] })
expect [0]->split_first_if(|x| x % 2 == 1) == Err(NotFound)

expect [0, 1]->split_last(1) == Ok({ before: [0], after: [] })
expect [0, 1]->split_last(0) == Ok({ before: [], after: [1] })
expect [0, 1, 2, 1, 0]->split_last(1) == Ok({ before: [0, 1, 2], after: [0] })
expect [0]->split_first(1) == Err(NotFound)

# split_last_if tests
expect [0, 1]->split_last_if(|x| x % 2 == 1) == Ok({ before: [0], after: [] })
expect [0, 1]->split_last_if(|x| x % 2 == 0) == Ok({ before: [], after: [1] })
expect [0, 1, 2, 3, 4]->split_last_if(|x| x % 2 == 1) == Ok({ before: [0, 1, 2], after: [4] })
expect [0]->split_last_if(|x| x % 2 == 1) == Err(NotFound)

# split_at_indices tests
expect []->split_at_indices([]) == [[]]
expect []->split_at_indices([0]) == [[]]
expect [0]->split_at_indices([]) == [[0]]
expect [0]->split_at_indices([0]) == [[0]]
expect [0]->split_at_indices([1]) == [[0]]
expect [0, 1]->split_at_indices([]) == [[0, 1]]
expect [0, 1]->split_at_indices([0]) == [[0, 1]]
expect [0, 1]->split_at_indices([1]) == [[0], [1]]
expect [0, 1]->split_at_indices([2]) == [[0, 1]]
expect [0, 1, 2, 3, 4, 5]->split_at_indices([1, 3]) == [[0], [1, 2], [3, 4, 5]]

# split_with_delims tests
expect []->split_with_delims(|x| x == 1) == []
expect [0]->split_with_delims(|x| x == 1) == [[0]]
expect [1]->split_with_delims(|x| x == 1) == [[1]]
expect [0, 1]->split_with_delims(|x| x == 1) == [[0], [1]]
expect [1, 0]->split_with_delims(|x| x == 1) == [[1], [0]]
expect [0, 1, 0, 0, 1, 0, 0, 0]->split_with_delims(|x| x == 1) == [[0], [1], [0, 0], [1], [0, 0, 0]]
expect split_with_delims(['0', '1', '2', '3', '4'], |c| List.contains(['0', '1'], c)) == [['0'], ['1'], ['2', '3', '4']]

# split_with_delims_head tests
expect []->split_with_delims_head(|x| x == 1) == []
expect [0]->split_with_delims_head(|x| x == 1) == [[0]]
expect [1]->split_with_delims_head(|x| x == 1) == [[1]]
expect [0, 1, 0, 0]->split_with_delims_head(|x| x == 1) == [[0], [1, 0, 0]]
expect [1, 0]->split_with_delims_head(|x| x == 1) == [[1, 0]]
expect [1, 0, 1, 0]->split_with_delims_head(|x| x == 1) == [[1, 0], [1, 0]]
expect [0, 0, 1, 0, 0, 1]->split_with_delims_head(|x| x == 1) == [[0, 0], [1, 0, 0], [1]]

# split_with_delims_tail tests
expect []->split_with_delims_tail(|x| x == 1) == []
expect [0]->split_with_delims_tail(|x| x == 1) == [[0]]
expect [1]->split_with_delims_tail(|x| x == 1) == [[1]]
expect [0, 1]->split_with_delims_tail(|x| x == 1) == [[0, 1]]
expect [1, 0]->split_with_delims_tail(|x| x == 1) == [[1], [0]]
expect [1, 1]->split_with_delims_tail(|x| x == 1) == [[1], [1]]
expect [0, 0]->split_with_delims_tail(|x| x == 1) == [[0, 0]]
expect [1, 0, 1]->split_with_delims_tail(|x| x == 1) == [[1], [0, 1]]
expect [0, 1, 0, 0]->split_with_delims_tail(|x| x == 1) == [[0, 1], [0, 0]]
expect [0, 1, 0, 0, 1, 0, 0, 0]->split_with_delims_tail(|x| x == 1) == [[0, 1], [0, 0, 1], [0, 0, 0]]
expect split_with_delims_tail(['a', 'b', '0', 'c', '1', 'd'], |c| List.contains(['0', '1'], c)) == [['a', 'b', '0'], ['c', '1'], ['d']]
