module [unwrap]

## Unwrap a Result, crashing with a message if the Result is an Err. This is unsafe and should only be used when you are certain that the Result cannot be an Err, or in expect statements.
## ```roc
## unwrap(Ok(5), "This should never crash") == 5
## ```
unwrap : Result a _, Str -> a
unwrap = |result, message|
    when result is
        Ok(value) -> value
        Err(_) -> crash(message)