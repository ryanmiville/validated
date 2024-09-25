import gleam/int
import gleam/regex
import gleam/string
import validated.{type Validated}

fn validate_password(password: String) -> Result(String, List(String)) {
  [
    min_length(_, 10),
    max_length(_, 28),
    must_not_contain(_, " "),
    contains_number,
    contains_capital_letter,
    contains_lowercase_letter,
    contains_symbol,
  ]
  |> validated.run_all(password)
  |> validated.replace(password)
  |> validated.to_result
}

pub fn main() {
  let assert Ok(_) = validate_password("Passw0r$1234")

  let assert Error([
    "does not meet minimum length of 10",
    "must contain a number",
    "must contain a capital letter",
    "must contain a symbol",
  ]) = validate_password("password")
}

fn min_length(s: String, min: Int) -> Validated(String, String) {
  case string.length(s) {
    len if len >= min -> Ok(s)
    _ -> Error("does not meet minimum length of " <> int.to_string(min))
  }
  |> validated.string
}

fn max_length(s: String, max: Int) -> Validated(String, String) {
  case string.length(s) {
    len if len <= max -> Ok(s)
    _ -> Error("exceeds maximum length of " <> int.to_string(max))
  }
  |> validated.string
}

fn must_not_contain(s: String, sub: String) -> Validated(String, String) {
  case string.contains(s, sub) {
    True -> Error("must not contain " <> sub)
    False -> Ok(s)
  }
  |> validated.string
}

fn contains_number(s: String) -> Validated(String, String) {
  match(s, ".*\\d.*", "must contain a number")
}

fn contains_capital_letter(s: String) -> Validated(String, String) {
  match(s, ".*[A-Z].*", "must contain a capital letter")
}

fn contains_lowercase_letter(s: String) -> Validated(String, String) {
  match(s, ".*[a-z].*", "must contain a lowercase letter")
}

fn contains_symbol(s: String) -> Validated(String, String) {
  match(s, ".*\\W+.*", "must contain a symbol")
}

fn match(
  s: String,
  pattern: String,
  error_message: String,
) -> Validated(String, String) {
  let assert Ok(re) = regex.from_string(pattern)
  case regex.check(re, s) {
    True -> Ok(s)
    False -> Error(error_message)
  }
  |> validated.string
}
