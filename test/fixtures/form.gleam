import gleam/regexp

pub type Form {
  Form(
    username: String,
    password: String,
    first_name: String,
    last_name: String,
    age: Int,
  )
}

pub fn validate_username(username: String) -> Result(String, String) {
  match(
    username,
    "^[a-zA-Z0-9]+$",
    "Username cannot contain special characters.",
  )
}

pub fn validate_password(password: String) -> Result(String, String) {
  match(
    password,
    "(?=^.{10,}$)((?=.*\\d)|(?=.*\\W+))(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$",
    "Password must be at least 10 characters long, including an uppercase and a lowercase letter, one number and one special character.",
  )
}

pub fn validate_first_name(first_name: String) -> Result(String, String) {
  match(
    first_name,
    "^[a-zA-Z]+$",
    "Last name cannot contain spaces, numbers or special characters.",
  )
}

pub fn validate_last_name(last_name: String) -> Result(String, String) {
  match(
    last_name,
    "^[a-zA-Z]+$",
    "Last name cannot contain spaces, numbers or special characters.",
  )
}

pub fn validate_age(age: Int) -> Result(Int, String) {
  case age {
    _ if age >= 18 && age <= 75 -> Ok(age)
    _ -> Error("You must be aged 18 and not older than 75 to use our services.")
  }
}

fn match(
  s: String,
  pattern: String,
  error_message: String,
) -> Result(String, String) {
  let assert Ok(re) = regexp.from_string(pattern)
  case regexp.check(re, s) {
    True -> Ok(s)
    False -> Error(error_message)
  }
}
