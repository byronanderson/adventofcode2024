defmodule Day07 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp example() do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
    |> parse()
  end

  defp input() do
    File.read!("day07.txt")
    |> parse()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [result, rest] = String.split(line, ": ")

      %{
        result: String.to_integer(result),
        operands: Enum.map(String.split(rest, " "), &String.to_integer/1)
      }
    end)
  end

  defp part1(input) do
    input
    |> Enum.filter(&valid_calibration?(&1, [:+, :*]))
    |> Enum.map(fn x -> x.result end)
    |> Enum.sum()
  end

  defp valid_calibration?(element, operators) do
    Enum.any?(results(operators, element.operands), fn result -> result == element.result end)
  end

  defp results(_, [number]), do: [number]

  defp results(operators, [number, other_number | rest]) do
    operators
    |> Stream.flat_map(fn
      :+ ->
        result = number + other_number
        results(operators, [result | rest])

      :* ->
        result = number * other_number
        results(operators, [result | rest])

      :|| ->
        power =
          (1 +
             :math.log10(other_number))
          |> floor()

        result = number * 10 ** power + other_number
        results(operators, [result | rest])
    end)
  end

  defp part2(input) do
    input
    |> Enum.filter(&valid_calibration?(&1, [:+, :*, :||]))
    |> Enum.map(fn x -> x.result end)
    |> Enum.sum()
  end
end

Day07.run()
