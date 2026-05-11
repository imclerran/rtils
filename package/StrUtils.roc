import ListUtils

StrUtils :: [].{

	## Split a string into substrings using a predicate function, dropping any matching delimiters.
	split_if : Str, (U8 -> Bool) -> List(Str)
	split_if = |str, predicate|
		Str.to_utf8(str)
			->ListUtils.split_if(predicate)
			->List.map(Str.from_utf8_lossy)

	## Returns the elements of a string before and after the first element matched by a predicate function.
	split_first_if : Str, (U8 -> Bool) -> Try({ before : Str, after : Str }, [NotFound])
	split_first_if = |str, predicate|
		Str.to_utf8(str)
			->ListUtils.split_first_if(predicate)
			->Try.map_ok(|{ before, after }| { before: Str.from_utf8_lossy(before), after: Str.from_utf8_lossy(after) })

	## Returns the elements of a string before and after the last element in the string matched by a predicate function.
	split_last_if : Str, (U8 -> Bool) -> Try({ before : Str, after : Str }, [NotFound])
	split_last_if = |str, predicate|
		Str.to_utf8(str)
			->ListUtils.split_last_if(predicate)
			->Try.map_ok(|{ before, after }| { before: Str.from_utf8_lossy(before), after: Str.from_utf8_lossy(after) })

	## Capitalize the first letter of a string. Lowercase the rest of it.
	capitalize : Str -> Str
	capitalize = |str| str.to_utf8()->capitalize_help()->Str.from_utf8_lossy()

	## Convert all ASCII letters in the string to uppercase.
	uppercase : Str -> Str
	uppercase = |str| str.to_utf8()->uppercase_help()->Str.from_utf8_lossy()

	## Convert all ASCII letters in the string to lowercase.
	lowercase : Str -> Str
	lowercase = |str| str.to_utf8()->lowercase_help()->Str.from_utf8_lossy()

	## Pad the string with the given character on the left until it reaches the target length. Returns an Error if the string contains characters that are not printable ASCII. If the padding character is not printable ASCII, it will be replaced with a space.
	## ```
	## expect pad_left("123", '_', 5) == Ok("__123")
	## expect pad_left("123", 127, 5) == Ok("  123")
	## expect pad_left("🔥", ' ', 2) == Err(InvalidASCII)
	## ```
	pad_left : Str, U8, U64 -> Try(Str, [InvalidASCII])
	pad_left = |str, char, target_length|
		if is_printed_ascii(str)
			Ok(pad_left_ascii(str, char, target_length))
		else
			Err(InvalidASCII)

	## Pad the string with the given character on the right until it reaches the target length. Returns an Error if the string contains characters that are not printable ASCII. If the padding character is not printable ASCII, it will be replaced with a space.
	## ```
	## expect pad_right("123", '_', 5) == Ok("123__")
	## expect pad_right("123", 127, 5) == Ok("123  ")
	## expect pad_right("🔥", ' ', 2) == Err(InvalidASCII)
	## ```
	pad_right : Str, U8, U64 -> Try(Str, [InvalidASCII])
	pad_right = |str, char, target_length|
		if is_printed_ascii(str)
			Ok(pad_right_ascii(str, char, target_length))
		else
			Err(InvalidASCII)
}

# ----- private helpers -----

capitalize_help : List(U8) -> List(U8)
capitalize_help = |bytes|
	match bytes {
		[first, .. as rest] =>
			if is_lowercase(first)
				[first - 32].concat(lowercase_help(rest))
			else
				[first].concat(lowercase_help(rest))

		[] => []
	}

uppercase_help : List(U8) -> List(U8)
uppercase_help = |bytes|
	match bytes {
		[first, .. as rest] =>
			if is_lowercase(first)
				[first - 32].concat(uppercase_help(rest))
			else
				[first].concat(uppercase_help(rest))

		[] => []
	}

lowercase_help : List(U8) -> List(U8)
lowercase_help = |bytes|
	match bytes {
		[first, .. as rest] =>
			if is_uppercase(first)
				[first + 32].concat(lowercase_help(rest))
			else
				[first].concat(lowercase_help(rest))

		[] => []
	}

is_lowercase : U8 -> Bool
is_lowercase = |c| 'a' <= c and c <= 'z'

is_uppercase : U8 -> Bool
is_uppercase = |c| 'A' <= c and c <= 'Z'

is_printed_ascii_char : U8 -> Bool
is_printed_ascii_char = |c| 32.U8 <= c and c <= 126.U8

is_printed_ascii : Str -> Bool
is_printed_ascii = |str| List.all(str.to_utf8(), is_printed_ascii_char)

pad_left_ascii : Str, U8, U64 -> Str
pad_left_ascii = |str, char, target_length| {
	bytes = str.to_utf8()
	cur_len = bytes.len()
	pad_len = if (target_length > cur_len) target_length - cur_len else 0
	pad_char = if is_printed_ascii_char(char) char else ' '
	pad = List.repeat(pad_char, pad_len)
	Str.from_utf8_lossy(pad.concat(bytes))
}

pad_right_ascii : Str, U8, U64 -> Str
pad_right_ascii = |str, char, target_length| {
	bytes = str.to_utf8()
	cur_len = bytes.len()
	pad_len = if (target_length > cur_len) target_length - cur_len else 0
	pad_char = if is_printed_ascii_char(char) char else ' '
	pad = List.repeat(pad_char, pad_len)
	Str.from_utf8_lossy(bytes.concat(pad))
}

# ----- tests -----

# split_if tests
expect "0123456789"->split_if(|c| c >= '0' and c <= '9') == []
expect "0123456789"->split_if(|c| c >= 'a' and c <= 'z') == ["0123456789"]
expect "0a123b45cd"->split_if(|c| c >= 'a' and c <= 'z') == ["0", "123", "45"]

# split_first_if tests
expect "0100010"->split_first_if(|c| c == '1') == Ok({ before: "0", after: "00010" })
expect "0100010"->split_first_if(|c| c == '0') == Ok({ before: "", after: "100010" })
expect "0100010"->split_first_if(|c| c == '2') == Err(NotFound)

# split_last_if tests
expect "0100010"->split_last_if(|c| c == '1') == Ok({ before: "01000", after: "0" })
expect "0100010"->split_last_if(|c| c == '0') == Ok({ before: "010001", after: "" })
expect "0100010"->split_last_if(|c| c == '2') == Err(NotFound)

# capitalize tests
expect "STRING"->capitalize() == "String"
expect "string"->capitalize() == "String"
expect " string"->capitalize() == " string"

expect pad_left("123", ' ', 5) == Ok("  123")
expect pad_left("🔥", ' ', 2) == Err(InvalidASCII)
expect pad_left(Str.from_utf8_lossy([1]), ' ', 2) == Err(InvalidASCII)

expect pad_right("123", ' ', 5) == Ok("123  ")
expect pad_right("🔥", ' ', 2) == Err(InvalidASCII)
expect pad_left([1]->Str.from_utf8_lossy(), ' ', 2) == Err(InvalidASCII)

expect pad_left_ascii("123", ' ', 5) == "  123"
expect pad_left_ascii("123", ' ', 2) == "123"
expect pad_left_ascii("123", 127, 5) == "  123"
expect pad_left_ascii("123", '_', 5) == "__123"
expect pad_left_ascii("🔥", ' ', 2) == "🔥"

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
