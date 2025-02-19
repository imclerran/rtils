module [approx_eq, approx_eq_out_to]

## Validate that a pair of fractional numbers are approximately equal (no more than 10^-6 difference).
## ```
## expect approx_eq(1.0, 0.999999)
## expect !approx_eq(1.0, 0.99999)
## ```
approx_eq : Frac a, Frac a -> Bool
approx_eq = |lhs, rhs| Num.abs(lhs - rhs) <= 0.000001

expect approx_eq(1.0, 0.999999)
expect approx_eq(1.0, 1.000001)
expect !approx_eq(1.0, 0.99999)
expect !approx_eq(1.0, 1.00001)

## Validate that a pair of fractional numbers are approximately equal (no more than than 10^-x difference).
## ```
## expect approx_eq_out_to(1.0, 0.99999, 5)
## expect !approx_eq_out_to(1.0, 0.99999, 6)
## ```
approx_eq_out_to : Frac a, Frac a, Num b -> Bool
approx_eq_out_to = |lhs, rhs, out_to| Num.abs(lhs - rhs) <= Num.pow(10, -Num.to_frac(out_to)) 

expect approx_eq_out_to(1.0, 0.99999, 5)
expect !approx_eq_out_to(1.0, 0.99999, 6)

