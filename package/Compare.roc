import ListUtils

Compare :: [].{

	## Compare two numbers for sorting in ascending order.
	## ```
	## List.sort_with([3, 1, 2], Compare.num_asc) == [1, 2, 3]
	## ```
	num_asc : number, number -> [LT, EQ, GT]
		where [
			number.is_lt : number, number -> Bool,
			number.is_gt : number, number -> Bool,
		]
	num_asc = |a, b| if a < b LT else if a > b GT else EQ

	## Compare two numbers for sorting in descending order.
	## ```
	## List.sort_with([3, 1, 2], Compare.num_desc) == [3, 2, 1]
	## ```
	num_desc : number, number -> [LT, EQ, GT]
		where [
			number.is_lt : number, number -> Bool,
			number.is_gt : number, number -> Bool,
		]
	num_desc = |a, b| num_asc(b, a)

	## Compare two strings for sorting in ascending order.
	## ```
	## List.sort_with(["apple", "Banana", "cherry"], Compare.str_asc) == ["Banana", "apple", "cherry"]
	## ```
	str_asc : Str, Str -> [LT, EQ, GT]
	str_asc = |a, b| {
		if a == b EQ
			else {
				bytes_a = a.to_utf8()
				bytes_b = b.to_utf8()
				var $idx = 0
				_ = for byte_a in bytes_a {
					match bytes_b.get($idx) {
						Ok(byte_b) if byte_a < byte_b => {
							return LT
						}
						Ok(byte_b) if byte_a > byte_b => {
							return GT
						}
						Ok(byte_b) if byte_a == byte_b => {}
						Err(OutOfBounds) => {
							return GT
						}
					}
					$idx = $idx + 1
				}
				if bytes_a.len() < bytes_b.len() {
					return LT
				}
				EQ
			}
	}

	## Compare two strings for sorting in descending order.
	## ```
	## List.sort_with(["apple", "Banana", "cherry"], Compare.str_desc) == ["cherry", "apple", "Banana"]
	## ```
	str_desc : Str, Str -> [LT, EQ, GT]
	str_desc = |a, b| str_asc(b, a)
}

# ----- private helpers -----

num_to_comparator : number -> [LT, EQ, GT]
	where [
		number.is_lt : number, number -> Bool,
		number.is_gt : number, number -> Bool,
		number.default : number,
	]
num_to_comparator = |n| {
	Num : number
	if n < Num.default LT else if n > Num.default GT else EQ
}

# ----- tests -----

expect str_asc("a", "b") == LT
expect str_asc("b", "a") == GT
expect str_asc("a", "a") == EQ
expect str_asc("a", "aa") == LT
expect str_asc("aa", "a") == GT
expect str_asc("A", "a") == LT
expect str_asc("a", "A") == GT
expect str_asc("a", "Aa") == GT
expect str_asc("Aa", "a") == LT

expect num_asc(1, 2) == LT
expect num_asc(2, 1) == GT
expect num_asc(1, 1) == EQ
expect num_asc(-0.1, 0.1) == LT
expect num_asc(0.1, -0.1) == GT
expect num_asc(-1, -2) == GT
expect num_asc(-2, -1) == LT
expect num_asc(0, 0) == EQ
