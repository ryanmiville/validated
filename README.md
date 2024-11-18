# validated

Easily accumulate errors in Gleam!

[![Package Version](https://img.shields.io/hexpm/v/validated)](https://hex.pm/packages/validated)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/validated/)

```gleam
import gleam/dict.{type Dict}
import validated.{type Validated, Invalid, Valid} as v

pub opaque type Config {
  Config(html: String, manifest: Dict(String, String), hash: String)
}

pub fn new(
  html_filepath: String,
  manifest_filepath: String,
) -> Validated(Config, String) {
  use html <- v.do(read_file(html_filepath) |> v.string)
  use data <- v.lazy_guard(read_file(manifest_filepath) |> v.string, empty)
  use manifest <- v.do(parse_manifest(data) |> v.dict)
  Valid(Config(html, manifest, hash(data)))
}

pub fn main() {
  let assert Valid(_) = new("exists.html", "exists.json")

  let assert Invalid(_, ["file not found", "file_not found"]) =
    new("not_there.html", "not_there.json")

  let assert Invalid(_, ["file not found", "failed to parse manifest"]) =
    new("not_there.html", "malformed.json")
}

fn empty() -> Config {
  Config("", dict.new(), "")
}
fn read_file(filepath: String) -> Result(String, String) { todo }
fn parse_manifest(data: String) -> Result(Dict(String, String), String) { todo }
fn hash(data: String) -> String { todo }
```

Further documentation can be found at <https://hexdocs.pm/validated>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
