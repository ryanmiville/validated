import gleam/dict
import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/list
import gleam/result
import validated.{type Validated}
import validated as v

pub type User {
  User(name: String, email: String, is_admin: Bool)
}

fn user_decoder(data: Dynamic) -> Result(User, DecodeErrors) {
  validate_user(data)
  |> v.to_result
  |> result.map_error(list.flatten)
}

fn validate_user(data: Dynamic) -> Validated(User, DecodeErrors) {
  use name <- v.try(v.string(dynamic.field("name", dynamic.string)(data)))
  use email <- v.try(v.string(dynamic.field("email", dynamic.string)(data)))
  use is_admin <- v.try(v.bool(dynamic.field("is-admin", dynamic.bool)(data)))
  v.valid(User(name:, email:, is_admin:))
}

pub fn main() {
  let data = user_data("Lucy", "lucy@example.com", True)
  let assert Ok(_) = user_decoder(data)

  let data = user_data(100, "lucy@example.com", True)
  let assert Error([_error]) = user_decoder(data)

  let data = user_data(100, 100, True)
  let assert Error([_error1, _error2]) = user_decoder(data)

  let data = user_data(100, 100, 100)
  let assert Error([_error1, _error2, _error3]) = user_decoder(data)
}

fn user_data(name: a, email: b, is_admin: c) {
  dynamic.from(
    dict.from_list([
      #("name", dynamic.from(name)),
      #("email", dynamic.from(email)),
      #("is-admin", dynamic.from(is_admin)),
    ]),
  )
}
