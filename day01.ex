defmodule Day01 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day01.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [first, second] = String.split(line, "   ")
      {String.to_integer(first), String.to_integer(second)}
    end)
  end

  defp part1(input) do
    first_sorted =
      input
      |> Enum.map(&elem(&1, 0))
      |> Enum.sort()

    second_sorted =
      input
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort()

    Stream.zip(first_sorted, second_sorted)
    |> Stream.map(fn {first, second} -> abs(first - second) end)
    |> Enum.reduce(0, fn a, b -> a + b end)
  end

  defp part2(input) do
    first_grouped =
      input
      |> Enum.map(&elem(&1, 0))
      |> Enum.group_by(& &1)

    second_grouped =
      input
      |> Enum.map(&elem(&1, 1))
      |> Enum.group_by(& &1)

    Enum.reduce(first_grouped, 0, fn {num, list}, acc ->
      acc + num * length(list) * length(Map.get(second_grouped, num, []))

      acc + three
    end)
  end
end

Day01.run()
