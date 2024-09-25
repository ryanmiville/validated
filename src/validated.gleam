import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None}

pub type Validated(a, e) {
  Valid(a)
  Invalid(a, List(e))
}

pub type Validator(in, out, error) =
  fn(in) -> Validated(out, error)

pub fn is_valid(validated: Validated(a, e)) -> Bool {
  case validated {
    Valid(_) -> True
    _ -> False
  }
}

pub fn is_invalid(validated: Validated(a, e)) -> Bool {
  case validated {
    Invalid(..) -> True
    _ -> False
  }
}

pub fn try(
  validated: Validated(a, e),
  next: fn(a) -> Validated(b, e),
) -> Validated(b, e) {
  case validated {
    Valid(a) -> next(a)
    Invalid(default, _) -> combine(validated, next(default))
  }
}

pub fn int(value: Result(Int, e)) -> Validated(Int, e) {
  result(value, 0)
}

pub fn string(value: Result(String, e)) -> Validated(String, e) {
  result(value, "")
}

pub fn float(value: Result(Float, e)) -> Validated(Float, e) {
  result(value, 0.0)
}

pub fn bool(value: Result(Bool, e)) -> Validated(Bool, e) {
  result(value, False)
}

pub fn list(value: Result(List(a), e)) -> Validated(List(a), e) {
  result(value, [])
}

pub fn bit_array(value: Result(BitArray, e)) -> Validated(BitArray, e) {
  result(value, <<>>)
}

pub fn optional(value: Result(Option(a), e)) -> Validated(Option(a), e) {
  result(value, None)
}

pub fn dict(value: Result(Dict(k, v), e)) -> Validated(Dict(k, v), e) {
  result(value, dict.new())
}

pub fn result(value: Result(a, e), default: a) -> Validated(a, e) {
  case value {
    Ok(a) -> Valid(a)
    Error(e) -> Invalid(default, [e])
  }
}

pub fn to_result(validated: Validated(a, e)) -> Result(a, List(e)) {
  case validated {
    Valid(a) -> Ok(a)
    Invalid(_, errors) -> Error(errors)
  }
}

pub fn map(validated: Validated(a, e), f: fn(a) -> b) -> Validated(b, e) {
  case validated {
    Valid(a) -> Valid(f(a))
    Invalid(default, errors) -> Invalid(f(default), errors)
  }
}

pub fn try_map(
  validated: Validated(a, e),
  default: b,
  f: fn(a) -> Result(b, e),
) -> Validated(b, e) {
  case validated {
    Valid(a) ->
      case f(a) {
        Ok(b) -> Valid(b)
        Error(e) -> Invalid(default, [e])
      }
    Invalid(_, errors) -> Invalid(default, errors)
  }
}

pub fn combine(v1: Validated(a, e), v2: Validated(b, e)) -> Validated(b, e) {
  case v1, v2 {
    Valid(_), _ -> v2
    Invalid(_, e), Valid(b) -> Invalid(b, e)
    Invalid(_, e1), Invalid(default, e2) ->
      Invalid(default, list.append(e1, e2))
  }
}

pub fn combine_all(vs: List(Validated(a, e)), default: a) -> Validated(a, e) {
  list.fold(vs, Valid(default), combine)
}

pub fn unwrap(validated: Validated(a, e)) -> a {
  case validated {
    Valid(a) -> a
    Invalid(a, _) -> a
  }
}

pub fn run(
  validator: Validator(in, out, error),
  input: in,
) -> Validated(out, error) {
  validator(input)
}

pub fn run_all(
  validators: List(Validator(in, out, error)),
  input: in,
) -> Validated(out, error) {
  let f = fn(acc, v) { combine(acc, v(input)) }
  case validators {
    [head, ..rest] -> list.fold(rest, head(input), f)
    [] -> panic as "list cannot be empty"
  }
}
