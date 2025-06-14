# Barcoder ![screenshot](barcode.svg)

[![Elixir CI](https://github.com/alekpopovic/barcoder/actions/workflows/elixir.yml/badge.svg)](https://github.com/alekpopovic/barcoder/actions/workflows/elixir.yml)


## Production-Ready Code 39 Barcode Generator

## Features

- Code 39 Support: Implements the widely-supported Code 39 barcode standard
- Input Validation: Validates characters before encoding to prevent runtime errors
- Multiple Output Formats:
- ASCII art for console/terminal display
- SVG format for web applications and printing
- Error Handling: Comprehensive error handling with descriptive messages
- Configurable Options: Customizable width, height, and quiet zones
- Production Ready: Includes proper documentation, validation, and error handling

## Supported Characters

- Numbers: 0-9
- Uppercase letters: A-Z
- Special characters: space, -, ., $, /, +, %

## Usage Examples

```elixir
# Basic ASCII output
{:ok, barcode} = BarcodeGenerator.generate("HELLO123")
IO.puts(barcode)

# SVG output for web use
{:ok, svg} = BarcodeGenerator.generate("PRODUCT001", format: :svg, width: 3, height: 50)
File.write!("barcode.svg", svg)

# Validate input
case BarcodeGenerator.validate_input("TEST123") do
  :ok -> IO.puts("Valid input")
  {:error, reason} -> IO.puts("Error: #{reason}")
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `barcoder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:barcoder, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/barcoder>.

