import fixtures/form.{type Form, Form}
import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import gleeunit
import gleeunit/should
import validated.{type Validated, type Validator, Invalid, Valid}
import validated as v

pub fn main() {
  gleeunit.main()
}

pub fn int_test() {
  v.int(Ok(1))
  |> should.equal(Valid(1))

  v.int(Error("oops"))
  |> should.equal(Invalid(0, ["oops"]))
}

pub fn float_test() {
  v.float(Ok(1.0))
  |> should.equal(Valid(1.0))

  v.float(Error("oops"))
  |> should.equal(Invalid(0.0, ["oops"]))
}

pub fn string_test() {
  v.string(Ok("hello"))
  |> should.equal(Valid("hello"))

  v.string(Error("oops"))
  |> should.equal(Invalid("", ["oops"]))
}

pub fn bool_test() {
  v.bool(Ok(True))
  |> should.equal(Valid(True))

  v.bool(Error("oops"))
  |> should.equal(Invalid(False, ["oops"]))
}

pub fn list_test() {
  v.list(Ok([1, 2]))
  |> should.equal(Valid([1, 2]))

  v.list(Error("oops"))
  |> should.equal(Invalid([], ["oops"]))
}

pub fn optional_test() {
  v.optional(Ok(Some("hi")))
  |> should.equal(Valid(Some("hi")))

  v.optional(Error("oops"))
  |> should.equal(Invalid(None, ["oops"]))
}

pub fn bit_array_test() {
  v.bit_array(Ok(<<"hello":utf8>>))
  |> should.equal(Valid(<<"hello":utf8>>))

  v.bit_array(Error("oops"))
  |> should.equal(Invalid(<<>>, ["oops"]))
}

pub fn dict_test() {
  v.dict(Ok(dict.from_list([#("hello", "world")])))
  |> should.equal(Valid(dict.from_list([#("hello", "world")])))

  v.dict(Error("oops"))
  |> should.equal(Invalid(dict.new(), ["oops"]))
}

pub fn map_test() {
  Valid(1)
  |> v.map(fn(a) { a + 1 })
  |> should.equal(Valid(2))

  Invalid(0, ["oops"])
  |> v.map(fn(a) { a + 1 })
  |> should.equal(Invalid(1, ["oops"]))
  // it runs against the default
}

pub fn try_test() {
  let valid_tuple = {
    use a <- v.do(Valid(1))
    use b <- v.do(Valid("hello"))
    Valid(#(a, b))
  }

  let invalid_tuple = {
    use a <- v.do(v.int(Error("oops")))
    use b <- v.do(Valid("hello"))
    Valid(#(a, b))
  }

  let cont = fn(tuple) {
    use tuple <- v.do(tuple)
    use bool <- v.do(Valid(True))
    Valid(#(tuple, bool))
  }

  cont(valid_tuple)
  |> v.to_result
  |> should.equal(Ok(#(#(1, "hello"), True)))

  cont(invalid_tuple)
  |> v.to_result
  |> should.equal(Error(["oops"]))
}

fn validator(
  cond: fn(in) -> Bool,
  true: out,
  false: error,
) -> Validator(in, out, error) {
  fn(in) {
    case cond(in) {
      True -> Valid(true)
      False -> Invalid(true, [false])
    }
  }
}

pub fn run_test() {
  let val = validator(string.contains(_, "ok"), Nil, "there's a problem")

  val
  |> v.run("this is ok")
  |> v.to_result
  |> should.equal(Ok(Nil))

  val
  |> v.run("oops")
  |> v.to_result
  |> should.equal(Error(["there's a problem"]))
}

pub fn run_all_test() {
  let min_length =
    validator(
      fn(in) { string.length(in) >= 8 },
      Nil,
      "must be at least 8 characters",
    )

  let no_spaces =
    validator(fn(in) { !string.contains(in, " ") }, Nil, "no spaces allowed")

  let vals = [min_length, no_spaces]

  vals
  |> v.run_all("asdfjkl;")
  |> v.to_result
  |> should.equal(Ok(Nil))

  vals
  |> v.run_all("hey joe")
  |> v.to_result
  |> should.equal(Error(["must be at least 8 characters", "no spaces allowed"]))

  []
  |> v.run_all("doesn't matter")
  |> v.to_result
  |> should.equal(Ok(Nil))
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

pub fn validate_form(
  username username: String,
  password password: String,
  first_name first_name: String,
  last_name last_name: String,
  age age: Int,
) -> Result(Form, List(String)) {
  do_validate_form(username, password, first_name, last_name, age)
  |> v.to_result
}

fn do_validate_form(
  username: String,
  password: String,
  first_name: String,
  last_name: String,
  age: Int,
) -> Validated(Form, String) {
  use username <- v.do(form.validate_username(username) |> v.string)
  use password <- v.do(form.validate_password(password) |> v.string)
  use first_name <- v.do(form.validate_first_name(first_name) |> v.string)
  use last_name <- v.do(form.validate_last_name(last_name) |> v.string)
  use age <- v.do(form.validate_age(age) |> v.int)
  Valid(Form(username:, password:, first_name:, last_name:, age:))
}
