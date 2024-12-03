defmodule Day02 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    # """
    # 7 6 4 2 1
    # 1 2 7 8 9
    # 9 7 6 2 1
    # 1 3 2 4 5
    # 8 6 4 4 1
    # 1 3 6 7 9
    # """

    File.read!("day02.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp part1(input) do
    input
    |> Enum.filter(&safe?/1)
    |> Enum.count()
  end

  defp safe?(row) do
    with {:ok, directionality} <- row |> determine_directionality() |> dbg() do
      row
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.all?(fn [first, second] ->
        safe?(directionality, first, second)
      end)
    end
  end

  defp safe?(:increasing, first, second) do
    (second - first) in 1..3
  end

  defp safe?(:decreasing, first, second) do
    (first - second) in 1..3
  end

  defp determine_directionality([_]), do: true

  defp determine_directionality([first, second | _rest]) do
    cond do
      first - second < 0 -> {:ok, :increasing}
      first - second > 0 -> {:ok, :decreasing}
      first == second -> false
    end
  end

  defp determine_directionality(_other), do: false

  defp part2(input) do
    input
    |> Enum.filter(&mostly_safe?/1)
    |> Enum.count()
  end

  defp mostly_safe?(row) do
    safe?(row) or
      Enum.any?(0..(length(row) - 1), fn index_to_remove ->
        row
        |> Enum.with_index()
        |> Enum.reject(fn {_, i} -> i == index_to_remove end)
        |> Enum.map(&elem(&1, 0))
        |> safe?()
      end)
  end
end

Day02.run()
