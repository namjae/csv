defmodule DecodingTests.ParsingTests.BaselineTest do
  use ExUnit.Case

  alias CSV.Decoding.Parser

  doctest Parser

  test "turns a sequence of tokens into a csv matrix" do
    parsed = Enum.map [
      {[
          {:content, "a"},
          {:separator, ","},
          {:content, "b"},
          {:delimiter, "\r\n"},
        ], 1}, {[
          {:content, "c"},
          {:separator, ","},
          {:content, "d"},
        ], 2}
    ], &Parser.parse/1

    assert parsed == [
      {:ok, ~w(a b), 1},
      {:ok, ~w(c d), 2}
    ]
  end

  test "turns a sequence of tokens into a csv matrix and strips cells" do
    parsed = Enum.map [
      {[
          {:content, " "},
          {:content, " "},
          {:content, "a"},
          {:content, " "},
          {:separator, ","},
          {:content, "b"},
          {:delimiter, "\r\n"},
        ], 1}, {[
          {:content, " "},
          {:content, "c"},
          {:separator, ","},
          {:content, " "},
          {:content, "d"},
          {:content, " "},
        ], 2}
    ], &Parser.parse(&1, strip_fields: true)

    assert parsed == [
      {:ok, ~w(a b), 1},
      {:ok, ~w(c d), 2}
    ]
  end

  test "turns a sequence of tokens with escape sequences into a csv matrix" do
    parsed = Enum.map [
      {[
          {:content, "a"},
          {:separator, ","},
          {:double_quote, "\""},
          {:content, "b"},
          {:delimiter, "\r\n"},
          {:content, "c"},
          {:separator, ","},
          {:double_quote, "\""},
        ], 1}, {[
          {:delimiter, "\r\n"},
          {:content, "c"},
          {:separator, ","},
          {:content, "d"},
        ], 2}
    ], &Parser.parse/1

    assert parsed == [
      {:ok, ["a", "b\r\nc,"], 1},
      {:ok, ["c", "d"], 2}
    ]
  end

  test "manages escaped double quotes inside double quoted fields according to RFC 4180" do
    parsed = Enum.map [
      {[
          {:content, "a"},
          {:separator, ","},
          {:double_quote, "\""},
          {:content, "b"},
          {:double_quote, "\""},
          {:double_quote, "\""},
          {:content, "c"},
          {:separator, ","},
          {:double_quote, "\""},
        ], 1}, {[
          {:delimiter, "\r\n"},
          {:content, "c"},
          {:separator, ","},
          {:content, "d"},
        ], 2}
    ], &Parser.parse/1

    assert parsed == [
      {:ok, ["a", "b\"c,"], 1},
      {:ok, ["c", "d"], 2}
    ]
  end

  test "manages escaped double quotes at the beginning of double quoted fields according to RFC 4180" do
    parsed = Enum.map [
      {[
          {:content, "a"},
          {:separator, ","},
          {:double_quote, "\""},
          {:double_quote, "\""},
          {:double_quote, "\""},
          {:content, "b"},
          {:content, "c"},
          {:separator, ","},
          {:double_quote, "\""},
        ], 1}, {[
          {:delimiter, "\r\n"},
          {:content, "c"},
          {:separator, ","},
          {:content, "d"},
        ], 2}
    ], &Parser.parse/1

    assert parsed == [
      {:ok, ["a", "\"bc,"], 1},
      {:ok, ["c", "d"], 2}
    ]
  end

end
