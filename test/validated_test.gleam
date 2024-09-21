import gleam/dict
import gleam/int
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import validated as v

pub fn main() {
  gleeunit.main()
}

pub fn int_test() {
  v.int(Ok(1))
  |> should.equal(v.valid(1))

  v.int(Error("oops"))
  |> should.equal(v.invalid(0, ["oops"]))
}

pub fn float_test() {
  v.float(Ok(1.0))
  |> should.equal(v.valid(1.0))

  v.float(Error("oops"))
  |> should.equal(v.invalid(0.0, ["oops"]))
}

pub fn string_test() {
  v.string(Ok("hello"))
  |> should.equal(v.valid("hello"))

  v.string(Error("oops"))
  |> should.equal(v.invalid("", ["oops"]))
}

pub fn bool_test() {
  v.bool(Ok(True))
  |> should.equal(v.valid(True))

  v.bool(Error("oops"))
  |> should.equal(v.invalid(False, ["oops"]))
}

pub fn list_test() {
  v.list(Ok([1, 2]))
  |> should.equal(v.valid([1, 2]))

  v.list(Error("oops"))
  |> should.equal(v.invalid([], ["oops"]))
}

pub fn optional_test() {
  v.optional(Ok(Some("hi")))
  |> should.equal(v.valid(Some("hi")))

  v.optional(Error("oops"))
  |> should.equal(v.invalid(None, ["oops"]))
}

pub fn bit_array_test() {
  v.bit_array(Ok(<<"hello":utf8>>))
  |> should.equal(v.valid(<<"hello":utf8>>))

  v.bit_array(Error("oops"))
  |> should.equal(v.invalid(<<>>, ["oops"]))
}

pub fn dict_test() {
  v.dict(Ok(dict.from_list([#("hello", "world")])))
  |> should.equal(v.valid(dict.from_list([#("hello", "world")])))

  v.dict(Error("oops"))
  |> should.equal(v.invalid(dict.new(), ["oops"]))
}

pub fn map_test() {
  v.valid(1)
  |> v.map(fn(a) { a + 1 })
  |> should.equal(v.valid(2))

  v.invalid(0, ["oops"])
  |> v.map(fn(a) { a + 1 })
  |> should.equal(v.invalid(1, ["oops"]))
  // it runs against the default
}

pub fn try_map_test() {
  let parse = fn(a) {
    case int.parse(a) {
      Ok(a) -> Ok(a)
      Error(Nil) -> Error("NaN")
    }
  }

  v.valid("1")
  |> v.try_map(0, parse)
  |> should.equal(v.valid(1))

  v.valid("one")
  |> v.try_map(0, parse)
  |> should.equal(v.invalid(0, ["NaN"]))

  v.invalid("", ["oops"])
  |> v.try_map(0, parse)
  |> should.equal(v.invalid(0, ["oops"]))
}

pub fn continue_test() {
  let valid_tuple = {
    use a <- v.try(v.valid(1))
    use b <- v.try(v.valid("hello"))
    v.valid(#(a, b))
  }

  let invalid_tuple = {
    use a <- v.try(v.int(Error("oops")))
    use b <- v.try(v.valid("hello"))
    v.valid(#(a, b))
  }

  let cont = fn(tuple) {
    use tuple <- v.try(tuple)
    use bool <- v.try(v.valid(True))
    v.valid(#(tuple, bool))
  }

  cont(valid_tuple)
  |> v.to_result
  |> should.equal(Ok(#(#(1, "hello"), True)))

  cont(invalid_tuple)
  |> v.to_result
  |> should.equal(Error(["oops"]))
}
