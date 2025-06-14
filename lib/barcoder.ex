defmodule Barcoder do
  @moduledoc """
  A production-ready Code 39 barcode generator without external dependencies.

  Code 39 can encode numbers, uppercase letters, and some special characters.
  Each barcode is automatically wrapped with start/stop characters (*).
  """

  # Code 39 character encoding patterns
  # Each pattern represents 9 elements: 5 bars and 4 spaces
  # '1' = wide element, '0' = narrow element
  @code39_patterns %{
    "0" => "000110100",
    "1" => "100100001",
    "2" => "001100001",
    "3" => "101100000",
    "4" => "000110001",
    "5" => "100110000",
    "6" => "001110000",
    "7" => "000100101",
    "8" => "100100100",
    "9" => "001100100",
    "A" => "100001001",
    "B" => "001001001",
    "C" => "101001000",
    "D" => "000011001",
    "E" => "100011000",
    "F" => "001011000",
    "G" => "000001101",
    "H" => "100001100",
    "I" => "001001100",
    "J" => "000011100",
    "K" => "100000011",
    "L" => "001000011",
    "M" => "101000010",
    "N" => "000010011",
    "O" => "100010010",
    "P" => "001010010",
    "Q" => "000000111",
    "R" => "100000110",
    "S" => "001000110",
    "T" => "000010110",
    "U" => "110000001",
    "V" => "011000001",
    "W" => "111000000",
    "X" => "010010001",
    "Y" => "110010000",
    "Z" => "011010000",
    "-" => "010000101",
    "." => "110000100",
    " " => "011000100",
    "$" => "010101000",
    "/" => "010100010",
    "+" => "010001010",
    "%" => "000101010",
    "*" => "010010100"
  }

  @valid_characters Map.keys(@code39_patterns) |> Enum.reject(&(&1 == "*"))

  @doc """
  Generates a Code 39 barcode for the given input string.

  ## Parameters
  - `input`: String to encode (numbers, uppercase letters, and some special characters)
  - `options`: Keyword list of options
    - `:format` - Output format (`:ascii` or `:svg`, default: `:ascii`)
    - `:width` - Bar width multiplier for SVG (default: 2)
    - `:height` - Bar height for SVG (default: 100)
    - `:quiet_zone` - Width of quiet zones (default: 10)

  ## Examples
      iex> Barcoder.generate("HELLO")
      {:ok, ascii_barcode_string}

      iex> Barcoder.generate("HELLO", format: :svg)
      {:ok, svg_string}

      iex> Barcoder.generate("hello")
      {:error, "Invalid character: 'h'. Only uppercase letters, numbers, and specific special characters are allowed."}
  """
  def generate(input, options \\ []) when is_binary(input) do
    with :ok <- validate_input(input),
         encoded_data <- encode_data(input),
         formatted_output <- format_output(encoded_data, options) do
      {:ok, formatted_output}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates a Code 39 barcode, raising an exception on error.

  ## Examples
      iex> Barcoder.generate!("HELLO")
      ascii_barcode_string
  """
  def generate!(input, options \\ []) do
    case generate(input, options) do
      {:ok, result} -> result
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Validates if the input string contains only supported characters.

  ## Examples
      iex> Barcoder.validate_input("HELLO123")
      :ok

      iex> Barcoder.validate_input("hello")
      {:error, "Invalid character: 'h'. Only uppercase letters, numbers, and specific special characters are allowed."}
  """
  def validate_input(input) when is_binary(input) do
    input
    |> String.graphemes()
    |> Enum.find(&(&1 not in @valid_characters))
    |> case do
      nil -> :ok
      invalid_char ->
        {:error, "Invalid character: '#{invalid_char}'. Only uppercase letters, numbers, and specific special characters are allowed."}
    end
  end

  @doc """
  Returns the list of valid characters that can be encoded.
  """
  def valid_characters, do: @valid_characters

  # Private functions

  defp encode_data(input) do
    # Add start and stop characters
    full_data = "*" <> String.upcase(input) <> "*"

    full_data
    |> String.graphemes()
    |> Enum.map(&Map.get(@code39_patterns, &1))
    |> Enum.join("0") # Add narrow space between characters
  end

  defp format_output(encoded_data, options) do
    format = Keyword.get(options, :format, :ascii)

    case format do
      :ascii -> format_ascii(encoded_data, options)
      :svg -> format_svg(encoded_data, options)
      _ -> raise ArgumentError, "Invalid format. Use :ascii or :svg"
    end
  end

  defp format_ascii(encoded_data, options) do
    quiet_zone = Keyword.get(options, :quiet_zone, 10)
    quiet_spaces = String.duplicate(" ", quiet_zone)

    bars = encoded_data
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {bit, index} ->
      if rem(index, 2) == 0 do # Bar positions (even indices)
        case bit do
          "1" -> "██" # Wide bar
          "0" -> "█"  # Narrow bar
        end
      else # Space positions (odd indices)
        case bit do
          "1" -> "  " # Wide space
          "0" -> " "  # Narrow space
        end
      end
    end)
    |> Enum.join()

    quiet_spaces <> bars <> quiet_spaces
  end

  defp format_svg(encoded_data, options) do
    width_multiplier = Keyword.get(options, :width, 2)
    height = Keyword.get(options, :height, 100)
    quiet_zone = Keyword.get(options, :quiet_zone, 10)

    {bars, total_width} = encoded_data
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce({[], quiet_zone}, fn {bit, index}, {acc, x_pos} ->
      if rem(index, 2) == 0 do # Bar positions (even indices)
        bar_width = if bit == "1", do: width_multiplier * 3, else: width_multiplier
        bar = ~s(<rect x="#{x_pos}" y="0" width="#{bar_width}" height="#{height}" fill="black"/>)
        {[bar | acc], x_pos + bar_width}
      else # Space positions (odd indices) - just advance position
        space_width = if bit == "1", do: width_multiplier * 3, else: width_multiplier
        {acc, x_pos + space_width}
      end
    end)

    final_width = total_width + quiet_zone

    ~s(<?xml version="1.0" encoding="UTF-8"?>
<svg width="#{final_width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">
  #{bars |> Enum.reverse() |> Enum.join("\n  ")}
</svg>)
  end
end
