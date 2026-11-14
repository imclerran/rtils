import ListUtils

Compare :: [].{

	## Compare two numbers for sorting in ascending order.
	## ```
	## List.sort_with([3, 1, 2], Compare.num_asc) == [1, 2, 3]
	## ```
	num_asc : number, number -> [Before, Same, After]
		where [
			number.is_lt : number, number -> Bool,
			number.is_gt : number, number -> Bool,
		]
	num_asc = |a, b| if (a < b) Before else if (a > b) After else Same

	## Compare two numbers for sorting in descending order.
	## ```
	## List.sort_with([3, 1, 2], Compare.num_desc) == [3, 2, 1]
	## ```
	num_desc : number, number -> [Before, Same, After]
		where [
			number.is_lt : number, number -> Bool,
			number.is_gt : number, number -> Bool,
		]
	num_desc = |a, b| num_asc(b, a)

	## Compare two strings for sorting in ascending order.
	## ```
	## List.sort_with(["apple", "Banana", "cherry"], Compare.str_asc) == ["Banana", "apple", "cherry"]
	## ```
	str_asc : Str, Str -> [Before, Same, After]
	str_asc = |a, b| {
		if (a == b) Same
		else {
			bytes_a = a.to_utf8()
			bytes_b = b.to_utf8()
			var $idx = 0
			_ = for byte_a in bytes_a {
				match bytes_b.get($idx) {
					Ok(byte_b) if byte_a < byte_b => {
						return Before
					}
					Ok(byte_b) if byte_a > byte_b => {
						return After
					}
					Ok(_) => {}
					Err(OutOfBounds) => {
						return After
					}
				}
				$idx = $idx + 1
			}
			if bytes_a.len() < bytes_b.len() {
				return Before
			}
			Same
		}
	}

	## Compare two strings for sorting in descending order.
	## ```
	## List.sort_with(["apple", "Banana", "cherry"], Compare.str_desc) == ["cherry", "apple", "Banana"]
	## ```
	str_desc : Str, Str -> [Before, Same, After]
	str_desc = |a, b| str_asc(b, a)
}

# ----- tests -----

expect Compare.str_asc("a", "b") == Before
expect Compare.str_asc("b", "a") == After
expect Compare.str_asc("a", "a") == Same
expect Compare.str_asc("a", "aa") == Before
expect Compare.str_asc("aa", "a") == After
expect Compare.str_asc("A", "a") == Before
expect Compare.str_asc("a", "A") == After
expect Compare.str_asc("a", "Aa") == After
expect Compare.str_asc("Aa", "a") == Before

expect Compare.num_asc(1, 2) == Before
expect Compare.num_asc(2, 1) == After
expect Compare.num_asc(1, 1) == Same
expect Compare.num_asc(-0.1, 0.1) == Before
expect Compare.num_asc(0.1, -0.1) == After
expect Compare.num_asc(-1, -2) == After
expect Compare.num_asc(-2, -1) == Before
expect Compare.num_asc(0, 0) == Same

expect List.sort_with([3, 1, 2], Compare.num_asc) == [1, 2, 3]
expect List.sort_with([3, 1, 2], Compare.num_desc) == [3, 2, 1]
expect List.sort_with(["apple", "Banana", "cherry"], Compare.str_asc) == ["Banana", "apple", "cherry"]
expect List.sort_with(["apple", "Banana", "cherry"], Compare.str_desc) == ["cherry", "apple", "Banana"]
