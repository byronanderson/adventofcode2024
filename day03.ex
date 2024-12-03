defmodule Day03 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day03.txt")
  end

  defp part1(input) do
    parse(input, 0)
  end

  @digits ?0..?9

  defp parse("", number), do: number

  defp parse("mul(" <> rest, number) do
    with {:ok, first_number, rest} <- consume_number(rest),
         {:ok, rest} <- consume(rest, ?,),
         {:ok, second_number, rest} <- consume_number(rest),
         {:ok, rest} <- consume(rest, ?)) do
      parse(rest, number + first_number * second_number)
    else
      _ -> parse(rest, number)
    end
  end

  defp parse(<<_other, rest::binary>>, number) do
    parse(rest, number)
  end

  defp consume_number(<<digit1, digit2, digit3, rest::binary>>)
       when digit1 in @digits and digit2 in @digits and digit3 in @digits do
    {:ok, String.to_integer(<<digit1, digit2, digit3>>), rest}
  end

  defp consume_number(<<digit1, digit2, rest::binary>>)
       when digit1 in @digits and digit2 in @digits do
    {:ok, String.to_integer(<<digit1, digit2>>), rest}
  end

  defp consume_number(<<digit1, rest::binary>>) when digit1 in @digits do
    {:ok, String.to_integer(<<digit1>>), rest}
  end

  defp consume_number(_other) do
    :error
  end

  defp consume(<<char, rest::binary>>, char) do
    {:ok, rest}
  end

  defp consume(_other, _char) do
    :error
  end

  defp part2(input) do
    parse2(input, :enabled, 0)
  end

  defp parse2("", enabled, number), do: number

  defp parse2("do()" <> rest, _, number) do
    parse2(rest, :enabled, number)
  end

  defp parse2("don't()" <> rest, _, number) do
    parse2(rest, :disabled, number)
  end

  defp parse2("mul(" <> rest, :enabled, number) do
    with {:ok, first_number, rest} <- consume_number(rest),
         {:ok, rest} <- consume(rest, ?,),
         {:ok, second_number, rest} <- consume_number(rest),
         {:ok, rest} <- consume(rest, ?)) do
      parse2(rest, :enabled, number + first_number * second_number)
    else
      _ -> parse2(rest, :enabled, number)
    end
  end

  defp parse2(<<_other, rest::binary>>, enabled, number) do
    parse2(rest, enabled, number)
  end
end

Day03.run()
