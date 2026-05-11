## Numeric utility functions for working with floating-point values.
##
## In particular, [is_approx_eq] and [is_approx_eq_to_places] provide
## IEEE 754-style hybrid (absolute + relative) tolerance comparison
NumUtils :: [].{

	## Test whether two F64 values are approximately equal, using a hybrid of
	## absolute and relative tolerance
	##
	##     |a - b| <= max(abs_tol, rel_tol * max(|a|, |b|))
	##
	## Defaults: `abs_tol = 1e-6`, `rel_tol = 1e-9`.
	##
	## ```
	## expect is_approx_eq(1.0, 0.999999)
	## expect !is_approx_eq(1.0, 0.99999)
	## ```
	is_approx_eq : F64, F64 -> Bool
	is_approx_eq = |a, b| is_approx_eq_with_tols(a, b, 0.000001, 0.000000001)

	## Test whether two F64 values are approximately equal to within
	## `10^-places` absolute tolerance, plus a small relative tolerance
	## (`1e-9`) so the check stays meaningful at large magnitudes:
	##
	##     |a - b| <= max(10^-places, 1e-9 * max(|a|, |b|))
	##
	## ```
	## expect is_approx_eq_to_places(1.0, 0.99999, 5)
	## expect !is_approx_eq_to_places(1.0, 0.99999, 6)
	## ```
	is_approx_eq_to_places : F64, F64, U64 -> Bool
	is_approx_eq_to_places = |a, b, places| {
		abs_tol = ten_pow_neg(places)
		is_approx_eq_with_tols(a, b, abs_tol, 0.000000001)
	}
}

# ----- private helpers -----

is_approx_eq_with_tols : F64, F64, F64, F64 -> Bool
is_approx_eq_with_tols = |a, b, abs_tol, rel_tol| {
	diff = (a - b).abs()
	scale = if a.abs() > b.abs() a.abs() else b.abs()
	rel_part = scale * rel_tol
	threshold = if rel_part > abs_tol rel_part else abs_tol
	diff <= threshold
}

# Compute 10^-n as a single division so we only round once, rather than
# accumulating error from n sequential `/ 10.0` operations.
ten_pow_neg : U64 -> F64
ten_pow_neg = |n| {
	var $power = 1.0
	var $i = 0
	while $i < n {
		$power = $power * 10.0
		$i = $i + 1
	}
	1.0 / $power
}

# ----- tests -----

# is_approx_eq tests — abs_tol = 1e-6
expect is_approx_eq(1.0, 1.0) # exact
expect is_approx_eq(1.0, 1.0000005) # diff ≈ 5e-7, clearly < 1e-6
expect is_approx_eq(1.0, 0.9999995) # diff ≈ 5e-7, clearly < 1e-6
expect !is_approx_eq(1.0, 1.00001) # diff ≈ 1e-5, clearly > 1e-6
expect !is_approx_eq(1.0, 0.99999) # diff ≈ 1e-5, clearly > 1e-6
expect !is_approx_eq(1.0, 0.5) # diff = 0.5, way out

# is_approx_eq_to_places tests — abs_tol = 10^-places
expect is_approx_eq_to_places(1.0, 1.0, 10) # exact, even at strict tol
expect is_approx_eq_to_places(1.0, 1.0000001, 5) # diff ≈ 1e-7, well within 10^-5
expect !is_approx_eq_to_places(1.0, 1.0001, 5) # diff ≈ 1e-4, outside 10^-5
expect is_approx_eq_to_places(1.0, 0.9999, 3) # diff ≈ 1e-4, well within 10^-3
expect !is_approx_eq_to_places(1.0, 0.9999, 5) # diff ≈ 1e-4, outside 10^-5
