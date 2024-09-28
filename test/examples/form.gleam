import gleam/list

import gleam/string
import validated.{type Validated, Valid}
import validated as v

pub opaque type Form {
  Form(email: String, age: Int)
}

pub fn valid_form(email: String, age: Int) -> Result(Form, List(String)) {
  do_valid_form(email, age) |> v.to_result
}

fn do_valid_form(email: String, age: Int) -> Validated(Form, String) {
  use email, is_valid <- v.do(validate_email(email))
  use email, _ <- v.do_if(
    when: is_valid,
    do: check_db_for_email(email),
    otherwise: email,
  )
  use age, _ <- v.do(validate_age(age))
  Valid(Form(email:, age:))
}

fn validate_email(email: String) -> Validated(String, String) {
  case string.contains(email, "@") {
    True -> Ok(email)
    False -> Error("email addresses must include '@'")
  }
  |> v.string
}

fn check_db_for_email(email: String) -> Validated(String, String) {
  let db = ["exists@example.com"]
  case list.contains(db, email) {
    True -> Ok(email)
    False -> Error("email address already exists")
  }
  |> v.string
}

fn validate_age(age: Int) -> Validated(Int, String) {
  case age >= 18 {
    True -> Ok(age)
    False -> Error("you must be 18 or older")
  }
  |> v.int
}

pub fn main() {
  let assert Ok(Form("lucy@example.com", 18)) =
    valid_form("lucy@example.com", 18)

  let assert Error(["email addresses must include '@'"]) =
    valid_form("lucy", 18)

  let assert Error([
    "email addresses must include '@'",
    "you must be 18 or older",
  ]) = valid_form("lucy", 1)
}
