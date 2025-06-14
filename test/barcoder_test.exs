defmodule BarcoderTest do
  use ExUnit.Case
  # doctest Barcoder

  describe "generate/2" do
    test "generates ASCII barcode for valid input" do
      assert {:ok, result} = Barcoder.generate("HELLO")
      assert is_binary(result)
      assert String.contains?(result, "█")
    end

    test "generates ASCII barcode with custom quiet zone" do
      {:ok, default_result} = Barcoder.generate("TEST")
      {:ok, custom_result} = Barcoder.generate("TEST", quiet_zone: 5)

      assert String.length(custom_result) < String.length(default_result)
    end

    test "generates SVG barcode for valid input" do
      assert {:ok, result} = Barcoder.generate("HELLO", format: :svg)
      assert is_binary(result)
      assert String.contains?(result, "<?xml")
      assert String.contains?(result, "<svg")
      assert String.contains?(result, "<rect")
    end

    test "generates SVG barcode with custom dimensions" do
      assert {:ok, result} = Barcoder.generate("TEST", format: :svg, width: 3, height: 150)
      assert String.contains?(result, ~s(height="150"))
    end

    test "handles numbers correctly" do
      assert {:ok, result} = Barcoder.generate("12345")
      assert is_binary(result)
    end

    test "handles special characters correctly" do
      assert {:ok, result} = Barcoder.generate("TEST-123.$")
      assert is_binary(result)
    end

    test "returns error for lowercase characters" do
      assert {:error, reason} = Barcoder.generate("hello")
      assert String.contains?(reason, "Invalid character")
      assert String.contains?(reason, "'h'")
    end

    test "returns error for unsupported special characters" do
      assert {:error, reason} = Barcoder.generate("TEST@123")
      assert String.contains?(reason, "Invalid character")
      assert String.contains?(reason, "'@'")
    end

    test "handles empty string" do
      assert {:ok, result} = Barcoder.generate("")
      assert is_binary(result)
    end

    test "raises error for invalid format" do
      assert_raise ArgumentError, "Invalid format. Use :ascii or :svg", fn ->
        Barcoder.generate("TEST", format: :invalid)
      end
    end
  end

  describe "generate!/2" do
    test "returns result directly for valid input" do
      result = Barcoder.generate!("HELLO")
      assert is_binary(result)
      assert String.contains?(result, "█")
    end

    test "raises ArgumentError for invalid input" do
      assert_raise ArgumentError, fn ->
        Barcoder.generate!("hello")
      end
    end

    test "generates SVG when format is specified" do
      result = Barcoder.generate!("TEST", format: :svg)
      assert String.contains?(result, "<?xml")
    end
  end

  describe "validate_input/1" do
    test "returns :ok for valid uppercase letters" do
      assert :ok = Barcoder.validate_input("HELLO")
    end

    test "returns :ok for valid numbers" do
      assert :ok = Barcoder.validate_input("12345")
    end

    test "returns :ok for valid special characters" do
      assert :ok = Barcoder.validate_input("TEST-123.$ /+%")
    end

    test "returns :ok for empty string" do
      assert :ok = Barcoder.validate_input("")
    end

    test "returns error for lowercase letters" do
      assert {:error, reason} = Barcoder.validate_input("hello")
      assert String.contains?(reason, "Invalid character: 'h'")
    end

    test "returns error for unsupported special characters" do
      assert {:error, reason} = Barcoder.validate_input("TEST@")
      assert String.contains?(reason, "Invalid character: '@'")
    end
  end

  describe "valid_characters/0" do
    test "returns list of valid characters" do
      characters = Barcoder.valid_characters()
      assert is_list(characters)
      assert "A" in characters
      assert "0" in characters
      assert "-" in characters
      refute "*" in characters  # Start/stop character should not be included
    end

    test "contains all expected character types" do
      characters = Barcoder.valid_characters()

      # Numbers 0-9
      Enum.each(0..9, fn i ->
        assert to_string(i) in characters
      end)

      # Uppercase letters A-Z
      Enum.each(?A..?Z, fn char ->
        assert <<char>> in characters
      end)

      # Special characters
      expected_special = ["-", ".", " ", "$", "/", "+", "%"]
      Enum.each(expected_special, fn char ->
        assert char in characters
      end)
    end
  end

  describe "output format validation" do
    test "ASCII output has proper structure" do
      {:ok, result} = Barcoder.generate("A", format: :ascii)

      assert String.contains?(result, "█")
      assert String.starts_with?(result, " ")  # Quiet zone
      assert String.ends_with?(result, " ")    # Quiet zone
    end

    test "SVG output is well-formed" do
      {:ok, result} = Barcoder.generate("A", format: :svg)

      assert String.starts_with?(result, "<?xml")
      assert String.contains?(result, "<svg")
      assert String.contains?(result, "</svg>")
      assert String.contains?(result, "<rect")
      assert String.contains?(result, ~s(fill="black"))
    end

    test "SVG respects custom dimensions" do
      {:ok, result} = Barcoder.generate("TEST",
        format: :svg,
        width: 5,
        height: 200
      )

      assert String.contains?(result, ~s(height="200"))
    end
  end

  describe "edge cases" do
    test "single character encoding" do
      assert {:ok, result} = Barcoder.generate("A")
      assert is_binary(result)
    end

    test "all valid special characters together" do
      special_chars = "-. $/+%"
      assert {:ok, result} = Barcoder.generate(special_chars)
      assert is_binary(result)
    end

    test "long string encoding" do
      long_string = String.duplicate("ABC123", 10)
      assert {:ok, result} = Barcoder.generate(long_string)
      assert is_binary(result)
    end
  end
end
