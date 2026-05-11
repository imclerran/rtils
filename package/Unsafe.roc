Unsafe :: [].{

	## Unwrap a Try value, crashing with a message if the Try is an Err. This is unsafe and should only be used when you are certain that the Try can never be an Err, or in expect statements.
	## ```roc
	## unwrap(Ok(5)) == 5
	## ```
	unwrap : Try(a, err) -> a
	unwrap = |try| {
		match try {
			Ok(value) => value
			Err(_) => {
				crash "This should never happen."
			}
		}
	}
}

expect unwrap(Ok(5)) == 5
