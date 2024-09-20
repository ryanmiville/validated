# validated

A library to make accumulating validation errors ergonomic and easy

[![Package Version](https://img.shields.io/hexpm/v/validated)](https://hex.pm/packages/validated)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/validated/)

```sh
gleam add validated@1
```
```gleam
import validated

pub type Credentials {
  Credentials(
    username: String,
    password: String,
  )
}

pub type CredentialsError {
  InvalidUsername
  InvalidPassword
}

pub fn validate_username(username: String) -> Result(String, CredentailsError) {
  let assert Ok(re) = regex.from_string("^[a-zA-Z0-9]+$")
  case regex.check(re, username) {
    True -> Ok(username)
    False -> Error(InvalidUsername)
  }
}

pub fn validate_password(password: String) -> Result(String, CredentialsError) {
  let assert Ok(re) =
    regex.from_string(
      "(?=^.{10,}$)((?=.*\\d)|(?=.*\\W+))(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$",
    )
  case regex.check(re, password) {
    True -> Ok(password)
    False -> Error(InvalidPassword)
  }
}

pub fn validate_form(
  username username: String,
  password password: String,
) -> Result(Credentials, List(CredentialsError)) {
  do_validate_form(username, password)
  |> validated.to_result
}

fn do_validate_form(
  username: String,
  password: String,
) -> Validated(Credentials, CredentialsError) {
  use username <- validated.string(validate_username(username))
  use password <- validated.string(validate_password(password))
  validated.valid(Credentials(username:, password:))
}

pub fn main() {
  let assert Ok(creds) =
    validate_form(username: "Joe", password: "Passw0r$1234")

  let assert Error([InvalidUsername]) =
    validate_form(username: "Joe%%%", password: "Passw0r$1234")

  let assert Error([InvalidUsername, InvalidPassword]) =
    validate_form(username: "Joe%%%", password: "password")
}
```

Further documentation can be found at <https://hexdocs.pm/validated>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
