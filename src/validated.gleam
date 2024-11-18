//// This module provides the `Validated` type and associated functions
//// to accumulate errors in an ergonomic way.
////
//// ## Example
//// ```gleam
//// fn validate_form(email: String, age: Int) -> Validated(Form, String) {
////   use email <- v.do(validate_email(email))
////   use age <- v.do(validate_age(age))
////   Valid(Form(email:, age:))
//// }
////
//// validated_form("lucy@example.com", 20)
//// // -> Valid(Form("lucy@example.com", 20))
////
//// validated_form("asdf", 5)
//// // -> Invalid(Form("", 0), ["not a valid email", "must be 18 or older"])
//// ```
////
//// This API is possible because a `Validated` requires a "default" value
//// in case of failure. That way, the default value is passed through to
//// continue the validation.
////
//// Since a value within a validation block may or may not be the default
//// value, it is important to **never perform side-effects inside the
//// validation**.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None}

/// `Validated` represents the result of something that may succeed or not.
/// It is similar to `Result`, except that it will accumulate multiple errors
/// instead of stopping at the first error.
/// `Valid` means it was successful, `Invalid` means it was not successful.
pub type Validated(a, e) {
  Valid(a)
  /// Invalid requires a default value to enable validation in `use` expressions
  Invalid(a, List(e))
}

/// A function that takes some input and returns a `Validated`
pub type Validator(in, out, error) =
  fn(in) -> Validated(out, error)

/// Checks whether the `Validated` is `Valid`
pub fn is_valid(validated: Validated(a, e)) -> Bool {
  case validated {
    Valid(_) -> True
    _ -> False
  }
}

/// Checks whether the `Validated` is `Invalid`
pub fn is_invalid(validated: Validated(a, e)) -> Bool {
  case validated {
    Invalid(..) -> True
    _ -> False
  }
}

/// "Updates" a `Valid` value by passing its value to a function that yields a `Validated`,
/// and returning the yielded `Validated`. (This may "replace" the `Valid` with an `Invalid`.)
///
/// If the input is an `Invalid` rather than an `Valid`, the function is still called using the default
/// value from the `Invalid`. If the function succeeds, the `Invalid`'s default is replaced with the `Valid` value.
/// If the function fails, the first `Invalid` errors are combined with the returned `Invalid` errors.
///
/// This function is useful in `use` expressions to ergonomically validate fields of a record
///
/// ## Examples
///
/// ```gleam
/// use a <- do(Valid(1))
/// use b <- do(Valid(2))
/// Valid(#(a, b))
/// // -> Valid(#(1, 2))
/// ```
///
/// ```gleam
/// use a <- do(Invalid(0, [Nil]))
/// use b <- do(Valid(2))
/// use c <- do(Invalid(0, [Nil]))
/// Valid(#(a, b, c))
/// // -> Invalid(#(0, 2, 0), [Nil, Nil])
/// ```
pub fn do(
  validated: Validated(a, e),
  next: fn(a) -> Validated(b, e),
) -> Validated(b, e) {
  case validated {
    Valid(a) -> next(a)
    Invalid(default, _) -> combine(validated, next(default))
  }
}

/// Creates a `Validated` from a `Result`.
/// It uses `0` as the default value in case of failure.
pub fn int(value: Result(Int, e)) -> Validated(Int, e) {
  result(value, 0)
}

/// Creates a `Validated` from a `Result`.
/// It uses an empty string as the default value in case of failure.
pub fn string(value: Result(String, e)) -> Validated(String, e) {
  result(value, "")
}

/// Creates a `Validated` from a `Result`.
/// It uses `0.0` as the default value in case of failure.
pub fn float(value: Result(Float, e)) -> Validated(Float, e) {
  result(value, 0.0)
}

/// Creates a `Validated` from a `Result`.
/// It uses `False` as the default value in case of failure.
pub fn bool(value: Result(Bool, e)) -> Validated(Bool, e) {
  result(value, False)
}

/// Creates a `Validated` from a `Result`.
/// It uses an empty list as the default value in case of failure.
pub fn list(value: Result(List(a), e)) -> Validated(List(a), e) {
  result(value, [])
}

/// Creates a `Validated` from a `Result`.
/// It uses an empty `BitArray` as the default value in case of failure.
pub fn bit_array(value: Result(BitArray, e)) -> Validated(BitArray, e) {
  result(value, <<>>)
}

/// Creates a `Validated` from a `Result`.
/// It uses `None` as the default value in case of failure.
pub fn optional(value: Result(Option(a), e)) -> Validated(Option(a), e) {
  result(value, None)
}

/// Creates a `Validated` from a `Result`.
/// It uses an empty `Dict` as the default value in case of failure.
pub fn dict(value: Result(Dict(k, v), e)) -> Validated(Dict(k, v), e) {
  result(value, dict.new())
}

/// Creates a `Validated` from a `Result`.
/// It requires a default value in case of failure.
pub fn result(value: Result(a, e), default: a) -> Validated(a, e) {
  case value {
    Ok(a) -> Valid(a)
    Error(e) -> Invalid(default, [e])
  }
}

/// Convert a `Validated` into a `Result`
pub fn to_result(validated: Validated(a, e)) -> Result(a, List(e)) {
  case validated {
    Valid(a) -> Ok(a)
    Invalid(_, errors) -> Error(errors)
  }
}

/// Updates a value held within the `Valid` of a `Validated` by calling a given function on it.
/// If the `Validated` is an `Invalid` rather than `Valid`, the function is called on the default value.
pub fn map(validated: Validated(a, e), f: fn(a) -> b) -> Validated(b, e) {
  case validated {
    Valid(a) -> Valid(f(a))
    Invalid(default, errors) -> Invalid(f(default), errors)
  }
}

/// Updates a value held within the `Invalid` of a `Validated` by calling a given function on it.
/// If the result is `Valid` rather than `Invalid` the function is not called and the result stays the same.
pub fn map_error(
  validated: Validated(a, e),
  f: fn(List(e)) -> List(f),
) -> Validated(a, f) {
  case validated {
    Valid(a) -> Valid(a)
    Invalid(default, errors) -> Invalid(default, f(errors))
  }
}

/// Combines the two `Validated` values.
/// If both are `Valid`, v2 is returned.
/// If there are any errors, `Invalid` is returned with all the errors
/// and the value of v2 if it is `Valid`, or its default value if it is `Invalid`.
fn combine(v1: Validated(a, e), v2: Validated(b, e)) -> Validated(b, e) {
  case v1, v2 {
    Valid(_), _ -> v2
    Invalid(_, e), Valid(b) -> Invalid(b, e)
    Invalid(_, e1), Invalid(default, e2) ->
      Invalid(default, list.append(e1, e2))
  }
}

/// Return the `Valid` value of the validated, or the default value if it is `Invalid`.
pub fn unwrap(validated: Validated(a, e)) -> a {
  case validated {
    Valid(a) -> a
    Invalid(a, _) -> a
  }
}

/// Run a `Validator` function.
pub fn run(
  validator: Validator(in, out, error),
  input: in,
) -> Validated(out, error) {
  validator(input)
}

/// Run all the `Validators` in order on the given input.
/// It will accumulate all the errors from all of the `Validators`.
///
/// If there are no errors, or if the list is empty, `Valid(Nil)` is returned.
pub fn run_all(
  validators: List(Validator(in, out, error)),
  input: in,
) -> Validated(Nil, error) {
  list.map(validators, run(_, input))
  |> all
  |> replace(Nil)
}

/// Combines a list of `Validateds` into a single `Validated`.
/// If all elements in the list are `Valid` then the function returns a `Valid`
/// holding the list of values.
/// Otherwise an `Invalid` is returned that combines all the errors.
/// `Valid([])` is returned if the list is empty.
pub fn all(validateds: List(Validated(a, e))) -> Validated(List(a), e) {
  let f = fn(acc, next) {
    case acc, next {
      Valid(aa), Valid(a) -> Valid([a, ..aa])
      Valid(aa), Invalid(a, e) -> Invalid([a, ..aa], e)
      Invalid(aa, e), Valid(a) -> Invalid([a, ..aa], e)
      Invalid(aa, e1), Invalid(a, e2) -> Invalid([a, ..aa], list.append(e1, e2))
    }
  }
  let validated = case validateds {
    [] -> Valid([])
    [head, ..rest] ->
      case head {
        Valid(a) -> list.fold(rest, Valid([a]), f)
        Invalid(a, e) -> list.fold(rest, Invalid([a], e), f)
      }
  }

  case validated {
    Valid(a) -> Valid(list.reverse(a))
    Invalid(a, e) -> Invalid(list.reverse(a), e)
  }
}

/// Merges a nested `Validated` into a single layer.
pub fn flatten(validated: Validated(Validated(a, e), e)) -> Validated(a, e) {
  case validated {
    Valid(Valid(a)) -> Valid(a)
    Valid(Invalid(a, errors)) -> Invalid(a, errors)
    Invalid(Valid(a), errors) -> Invalid(a, errors)
    Invalid(Invalid(a, e1), e2) -> Invalid(a, list.append(e1, e2))
  }
}

/// Replace the value within a `Validated`
pub fn replace(validated: Validated(a, e), value: b) -> Validated(b, e) {
  case validated {
    Valid(_) -> Valid(value)
    Invalid(_, errors) -> Invalid(value, errors)
  }
}

/// Like `do`, but does not continue accumulating further errors if the
/// `Validated` is `Invalid`.
pub fn guard(
  validated: Validated(a, e),
  default: b,
  continue: fn(a) -> Validated(b, e),
) -> Validated(b, e) {
  case validated {
    Valid(a) -> continue(a)
    Invalid(_, e) -> Invalid(default, e)
  }
}

/// Like `guard` but accepts a callback for the default value in case the
/// `Validated` is `Invalid`.
pub fn lazy_guard(
  validated: Validated(a, e),
  default: fn() -> b,
  continue: fn(a) -> Validated(b, e),
) -> Validated(b, e) {
  case validated {
    Valid(a) -> continue(a)
    Invalid(_, e) -> Invalid(default(), e)
  }
}
