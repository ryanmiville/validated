import gleam/regex
import gleeunit
import gleeunit/should
import validated.{type Validated, Valid}
import validated as v

pub fn main() {
  gleeunit.main()
}

pub fn validate_form_test() {
  validate_form(
    username: "Joe",
    password: "Passw0r$1234",
    first_name: "John",
    last_name: "Doe",
    age: 21,
  )
  |> should.equal(
    Ok(Form(
      username: "Joe",
      password: "Passw0r$1234",
      first_name: "John",
      last_name: "Doe",
      age: 21,
    )),
  )

  validate_form(
    username: "Joe%%%",
    password: "password",
    first_name: "John",
    last_name: "Doe",
    age: 21,
  )
  |> should.equal(
    Error([
      "Username cannot contain special characters.",
      "Password must be at least 10 characters long, including an uppercase and a lowercase letter, one number and one special character.",
    ]),
  )
}

pub type Form {
  Form(
    username: String,
    password: String,
    first_name: String,
    last_name: String,
    age: Int,
  )
}

pub fn validate_form(
  username username: String,
  password password: String,
  first_name first_name: String,
  last_name last_name: String,
  age age: Int,
) -> Result(Form, List(String)) {
  do_validate_form(username, password, first_name, last_name, age)
  |> validated.to_result
}

fn do_validate_form(
  username: String,
  password: String,
  first_name: String,
  last_name: String,
  age: Int,
) -> Validated(Form, String) {
  use username <- v.try(validate_username(username))
  use password <- v.try(validate_password(password))
  use first_name <- v.try(validate_first_name(first_name))
  use last_name <- v.try(validate_last_name(last_name))
  use age <- v.try(validate_age(age))
  Valid(Form(username:, password:, first_name:, last_name:, age:))
}

fn validate_username(username: String) -> Validated(String, String) {
  match(
    username,
    "^[a-zA-Z0-9]+$",
    "Username cannot contain special characters.",
  )
}

fn validate_password(password: String) -> Validated(String, String) {
  match(
    password,
    "(?=^.{10,}$)((?=.*\\d)|(?=.*\\W+))(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$",
    "Password must be at least 10 characters long, including an uppercase and a lowercase letter, one number and one special character.",
  )
}

fn validate_first_name(first_name: String) -> Validated(String, String) {
  match(
    first_name,
    "^[a-zA-Z]+$",
    "Last name cannot contain spaces, numbers or special characters.",
  )
}

fn validate_last_name(last_name: String) -> Validated(String, String) {
  match(
    last_name,
    "^[a-zA-Z]+$",
    "Last name cannot contain spaces, numbers or special characters.",
  )
}

fn validate_age(age: Int) -> Validated(Int, String) {
  case age {
    _ if age >= 18 && age <= 75 -> Ok(age)
    _ -> Error("You must be aged 18 and not older than 75 to use our services.")
  }
  |> v.int
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
