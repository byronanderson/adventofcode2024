defmodule Day11 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 55312

    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day11.txt")
    |> parse()
  end

  defp example() do
    """
    125 17
    """
    |> parse()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp part1(input) do
    calculate(input, 25)
  end

  defp evolve(data) do
    Stream.flat_map(data, fn el ->
      cond do
        el == 0 -> [1]
        even_digits(el) -> divide(el)
        el -> [el * 2024]
      end
    end)
  end

  defp even_digits(el), do: rem(byte_size(to_string(el)), 2) == 0

  defp divide(number) do
    string = to_string(number)
    digits = div(byte_size(string), 2)
    first = String.slice(string, 0..(digits - 1))
    second = String.slice(string, digits..(2 * digits - 1))
    [String.to_integer(first), String.to_integer(second)]
  end

  defp how_many_eventually(_el, 0, state), do: {1, state}

  defp how_many_eventually(el, iterations, state) do
    case Map.fetch(state, {el, iterations}) do
      {:ok, count} ->
        {count, state}

      :error ->
        {answer, state} =
          evolve([el])
          |> Enum.reduce({0, state}, fn el, {count, state} ->
            {answer, state} = how_many_eventually(el, iterations - 1, state)
            {answer + count, state}
          end)

        {answer, state |> Map.put({el, iterations}, answer)}
    end
  end

  defp part2(input) do
    calculate(input, 75)
  end

  defp calculate(input, iterations) do
    input
    |> Enum.reduce({0, %{}}, fn el, {count, state} ->
      {answer, state} = how_many_eventually(el, iterations, state)
      {answer + count, state}
    end)
    |> elem(0)
  end
end

Day11.run()
