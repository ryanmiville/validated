import gleam/string
import validated.{type Validated}
import validated as v

pub opaque type Form {
  Form(email: String, age: Int)
}

pub fn valid_form(email: String, age: Int) -> Result(Form, List(String)) {
  do_valid_form(email, age) |> v.to_result
}

fn do_valid_form(email: String, age: Int) -> Validated(Form, String) {
  use email <- v.field(validate_email(email))
  use age <- v.field(validate_age(age))
  v.valid(Form(email:, age:))
}

fn validate_email(email: String) -> Validated(String, String) {
  case string.contains(email, "@") {
    True -> Ok(email)
    False -> Error("email addresses must include '@'")
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

fn is_something(a: String) -> Bool {
  todo
}

fn wrap(a: Result(String, String)) {
  todo
}

fn thing1(a: String) {
  case is_something(a) {
    True -> Ok(a)
    False -> Error("bad")
  }
  |> wrap
}

fn thing2(a: String) {
  wrap(case is_something(a) {
    True -> Ok(a)
    False -> Error("bad")
  })
}

fn thing3(a: String) {
  let result = case is_something(a) {
    True -> Ok(a)
    False -> Error("bad")
  }
  wrap(result)
}
