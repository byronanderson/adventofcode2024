defmodule DayXX do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 0

    part1(input())
    |> IO.inspect(label: :part1)

    assert part2(example()) == 0

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("dayXX.txt")
    |> parse()
  end

  defp example() do
    """
    """
    |> parse()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, char}
      end)
    end)
    |> Map.new()
  end

  defp part1(input) do
  end

  defp part2(input) do
  end
end

DayXX.run()
