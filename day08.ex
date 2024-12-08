defmodule Day08 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 14

    part1(input())
    |> IO.inspect(label: :part1)

    assert part2(example()) == 34

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day08.txt")
    |> parse()
  end

  defp example() do
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
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

  defp antinodes(input, multiple \\ 1) do
    boundary = find_boundary(input)

    frequencies(input)
    |> Stream.flat_map(&frequency_antinodes(input, &1, boundary, multiple))
  end

  defp find_boundary(input) do
    input
    |> Map.keys()
    |> MapSet.new()
  end

  defp frequencies(input) do
    MapSet.new(input, fn {_, char} -> char end)
    |> MapSet.delete(".")
  end

  defp frequency_antinodes(input, frequency, boundary, multiple) do
    frequency_nodes =
      input
      |> Enum.filter(fn {_, char} -> char == frequency end)
      |> Enum.map(fn {location, _} -> location end)

    for node1 <- frequency_nodes,
        node2 <- frequency_nodes,
        node1 != node2,
        antinode <- antinodes(node1, node2, multiple),
        antinode in boundary do
      antinode
    end
  end

  defp antinodes({x1, y1}, {x2, y2}, multiple) do
    [{x1 - multiple * (x2 - x1), y1 - multiple * (y2 - y1)}]
  end

  defp part1(input) do
    antinodes(input)
    |> MapSet.new()
    |> Enum.count()
  end

  defp part2(input) do
    find_antinodes(input, MapSet.new(), 0)
    |> MapSet.size()
  end

  defp find_antinodes(input, acc, multiple) do
    new_antinodes = MapSet.new(antinodes(input, multiple))

    if Enum.empty?(new_antinodes) do
      acc
    else
      find_antinodes(input, MapSet.union(new_antinodes, acc), multiple + 1)
    end
  end
end

Day08.run()
