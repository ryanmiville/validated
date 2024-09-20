import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None}
import gleam/result

pub opaque type Validated(a, e) {
  Validated(default: a, result: Result(a, List(e)))
}

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
    Ok(_) -> False
    _ -> True
  }
}

pub fn field(
  validated: Validated(a, e),
  next: fn(a) -> Validated(b, e),
) -> Validated(b, e) {
  case validated.result {
    Ok(a) -> next(a)
    Error(e1) -> {
      case next(validated.default) {
        Validated(_, Ok(b)) -> invalid(b, e1)
        Validated(next_default, Error(e2)) ->
          invalid(next_default, list.append(e1, e2))
      }
    }
  }
}

pub fn int(result: Result(Int, e)) -> Validated(Int, e) {
  from_result(result, 0)
}

pub fn string(result: Result(String, e)) -> Validated(String, e) {
  from_result(result, "")
}

pub fn float(result: Result(Float, e)) -> Validated(Float, e) {
  from_result(result, 0.0)
}

pub fn bool(result: Result(Bool, e)) -> Validated(Bool, e) {
  from_result(result, False)
}

pub fn list(result: Result(List(a), e)) -> Validated(List(a), e) {
  from_result(result, [])
}

pub fn bit_array(result: Result(BitArray, e)) -> Validated(BitArray, e) {
  from_result(result, <<>>)
}

pub fn optional(result: Result(Option(a), e)) -> Validated(Option(a), e) {
  from_result(result, None)
}

pub fn dict(result: Result(Dict(k, v), e)) -> Validated(Dict(k, v), e) {
  from_result(result, dict.new())
}

pub fn from_result(result: Result(a, e), default: a) -> Validated(a, e) {
  Validated(result.unwrap(result, default), result.map_error(result, list.wrap))
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
