import gleam/int
import gleam/regex
import gleam/string
import validated.{type Validated}
import validated as v

fn min_length(s: String, min: Int) -> Validated(String, String) {
  case string.length(s) {
    len if len >= min -> Ok(s)
    _ -> Error("does not meet minimum length of " <> int.to_string(min))
  }
  |> v.string
}

fn max_length(s: String, max: Int) -> Validated(String, String) {
  case string.length(s) {
    len if len <= max -> Ok(s)
    _ -> Error("exceeds maximum length of " <> int.to_string(max))
  }
  |> v.string
}

fn must_not_contain(s: String, sub: String) -> Validated(String, String) {
  case string.contains(s, sub) {
    True -> Error("must not contain " <> sub)
    False -> Ok(s)
  }
  |> v.string
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
  |> v.string
}

fn validate_password(password: String) -> Result(String, List(String)) {
  password
  |> do_validate_password
  |> v.to_result
}

fn do_validate_password(password: String) -> Validated(String, String) {
  use _ <- v.try(min_length(password, 10))
  use _ <- v.try(max_length(password, 28))
  use _ <- v.try(must_not_contain(password, " "))
  use _ <- v.try(contains_number(password))
  use _ <- v.try(contains_capital_letter(password))
  use _ <- v.try(contains_lowercase_letter(password))
  v.valid(password)
}

pub fn main() {
  let assert Ok(_) = validate_password("Passw0r$1234")

  let assert Error([
    "does not meet minimum length of 10",
    "must contain a number",
    "must contain a capital letter",
  ]) = validate_password("password")
}
