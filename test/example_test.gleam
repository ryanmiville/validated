import gleam/regex
import gleeunit
import gleeunit/should
import validated.{type Validated}
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
  use username <- v.field(validate_username(username))
  use password <- v.field(validate_password(password))
  use first_name <- v.field(validate_first_name(first_name))
  use last_name <- v.field(validate_last_name(last_name))
  use age <- v.field(validate_age(age))
  v.valid(Form(username:, password:, first_name:, last_name:, age:))
}

fn validate_username(username: String) -> Validated(String, String) {
  let assert Ok(re) = regex.from_string("^[a-zA-Z0-9]+$")
  case regex.check(re, username) {
    True -> Ok(username)
    False -> Error("Username cannot contain special characters.")
  }
  |> v.string
}

fn validate_password(password: String) -> Validated(String, String) {
  let assert Ok(re) =
    regex.from_string(
      "(?=^.{10,}$)((?=.*\\d)|(?=.*\\W+))(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$",
    )
  case regex.check(re, password) {
    True -> Ok(password)
    False ->
      Error(
        "Password must be at least 10 characters long, including an uppercase and a lowercase letter, one number and one special character.",
      )
  }
  |> v.string
}

fn validate_first_name(first_name: String) -> Validated(String, String) {
  let assert Ok(re) = regex.from_string("^[a-zA-Z]+$")
  case regex.check(re, first_name) {
    True -> Ok(first_name)
    False ->
      Error("First name cannot contain spaces, numbers or special characters.")
  }
  |> v.string
}

fn validate_last_name(last_name: String) -> Validated(String, String) {
  let assert Ok(re) = regex.from_string("^[a-zA-Z]+$")
  case regex.check(re, last_name) {
    True -> Ok(last_name)
    False ->
      Error("Last name cannot contain spaces, numbers or special characters.")
  }
  |> v.string
}

fn validate_age(age: Int) -> Validated(Int, String) {
  case age {
    _ if age >= 18 && age <= 75 -> Ok(age)
    _ -> Error("You must be aged 18 and not older than 75 to use our services.")
  }
  |> v.int
}
