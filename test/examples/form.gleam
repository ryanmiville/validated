// import gleam/list

// import gleam/string
// import validated/decode_api.{type Validated, Invalid, Valid}
// import validated/decode_api as v

// pub type Form {
//   Form(email: String, age: Int)
// }

// fn new1(email: String, age: Int) -> Validated(Form, String) {
//   use <- v.do(validate_email(email))
//   use <- v.do(validate_age(age))
//   Valid(Form(email:, age:))
// }

// fn new2(email: String, age: Int) -> Validated(Form, String) {
//   v.validate({
//     use email <- v.parameter
//     use age <- v.parameter
//     Form(email:, age:)
//   })
//   |> v.field(validate_email(email))
//   |> v.field(validate_age(age))
// }

// fn validate_email(email: String) -> Validated(String, String) {
//   use <- v.guard(check_email_format(email))
//   check_db_for_email(email)
// }

// fn check_email_format(email: String) -> Validated(String, String) {
//   case string.contains(email, "@") {
//     True -> Valid(email)
//     False -> Invalid(["email addresses must include '@'"])
//   }
// }

// fn check_db_for_email(email: String) -> Validated(String, String) {
//   let db = ["exists@example.com"]
//   case list.contains(db, email) {
//     False -> Valid(email)
//     True -> Invalid(["email address already exists"])
//   }
// }

// fn validate_age(age: Int) -> Validated(Int, String) {
//   case age >= 18 {
//     True -> Valid(age)
//     False -> Invalid(["you must be 18 or older"])
//   }
// }

// pub fn main() {
//   let assert Valid(Form("lucy@example.com", 18)) = new1("lucy@example.com", 18)

//   let assert Invalid(["email addresses must include '@'"]) = new1("lucy", 18)

//   let assert Invalid([
//     "email addresses must include '@'",
//     "you must be 18 or older",
//   ]) = new1("lucy", 1)

//   let assert Valid(Form("lucy@example.com", 18)) = new2("lucy@example.com", 18)
//   let assert Invalid(["email addresses must include '@'"]) = new2("lucy", 18)

//   let assert Invalid([
//     "email addresses must include '@'",
//     "you must be 18 or older",
//   ]) = new2("lucy", 1)
// }
