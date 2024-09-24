import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None}
import gleam/result

pub type Validated(a, e) {
  Validated(default: a, result: Result(a, List(e)))
}

pub type Validator(in, out, error) =
  fn(in) -> Validated(out, error)

pub fn valid(value: a) -> Validated(a, e) {
  Validated(value, Ok(value))
}

pub fn invalid(default: a, errors: List(e)) -> Validated(a, e) {
  Validated(default, Error(errors))
}

pub fn is_valid(validated: Validated(a, e)) -> Bool {
  case validated.result {
    Ok(_) -> True
    _ -> False
  }
}

pub fn is_invalid(validated: Validated(a, e)) -> Bool {
  case validated.result {
    Error(_) -> True
    _ -> False
  }
}

pub fn try(
  validated: Validated(a, e),
  next: fn(a) -> Validated(b, e),
) -> Validated(b, e) {
  case validated.result {
    Ok(a) -> next(a)
    _ -> combine(validated, next(validated.default))
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
  Validated(result.unwrap(value, default), result.map_error(value, list.wrap))
}

pub fn to_result(validated: Validated(a, e)) -> Result(a, List(e)) {
  validated.result
}

pub fn map(validated: Validated(a, e), f: fn(a) -> b) -> Validated(b, e) {
  case validated.result {
    Ok(a) -> valid(f(a))
    Error(e) -> invalid(f(validated.default), e)
  }
}

pub fn try_map(
  validated: Validated(a, e),
  default: b,
  f: fn(a) -> Result(b, e),
) -> Validated(b, e) {
  case validated.result {
    Ok(a) ->
      case f(a) {
        Ok(b) -> valid(b)
        Error(e) -> invalid(default, [e])
      }
    Error(e) -> invalid(default, e)
  }
}

pub fn combine(v1: Validated(a, e), v2: Validated(b, e)) -> Validated(b, e) {
  case v1.result, v2.result {
    Ok(_), _ -> v2
    Error(e), Ok(b) -> invalid(b, e)
    Error(e1), Error(e2) -> invalid(v2.default, list.append(e1, e2))
  }
}

pub fn combine_all(vs: List(Validated(a, e)), default: a) -> Validated(a, e) {
  list.fold(vs, valid(default), combine)
}

pub fn unwrap(validated: Validated(a, e)) -> a {
  case validated {
    Validated(_, Ok(a)) -> a
    Validated(a, _) -> a
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
