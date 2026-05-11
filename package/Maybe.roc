Maybe(a) :: [Some(a), None].{

    ## Construct a Some value
    some : a -> Maybe(a)
    some = |v| Some(v)

    ## Construct a None value
    none : Maybe(_)
    none = None

    ## Compare to Maybe values for equality
    is_eq : Maybe(a), Maybe(a) -> Bool
        where [a.is_eq : a, a -> Bool]
    is_eq = |lhs, rhs| {
        match (lhs, rhs) {
            (Some(lv), Some(rv)) => lv == rv
            (None, None) => Bool.True
            _ => Bool.False
        }
    }

    ## Map a function over the value inside a Maybe, if it exists
    map : Maybe(a), (a -> b) -> Maybe(b)
    map = |m, f| {
        match m {
            Some(v) => Some(f(v))
            None => None
        }
    }

    ## Extract the value from a Maybe, or return a default if it is None
    with_default : Maybe(a), a -> a
    with_default = |m, dv| {
        match m {
            Some(v) => v
            None => dv
        }
    }

    ## Convert a Try value to a Maybe
    from_try : Try(a, err) -> Maybe(a)
    from_try = |t| {
        match t {
            Ok(v) => Some(v)
            Err(_) => None
        }
    }
}

# ----- tests -----

# some and none tests
expect some(1) == some(1)
expect some(1) != some(2)
expect some(1) != none
expect none == none

# map tests
expect some(1).map(|a| a + 1) == some(2)

# with default tests
expect some(2).with_default(1) == 2
expect none.with_default(1) == 1

# from_try tests
expect Ok(1)->from_try == some(1)
expect Err(E)->from_try == none
