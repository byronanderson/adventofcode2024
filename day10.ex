defmodule Day10 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 36

    part1(input())
    |> IO.inspect(label: :part1)

    assert part2(example()) == 81

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day10.txt")
    |> parse()
  end

  defp example() do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
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
        {{x, y}, String.to_integer(char)}
      end)
    end)
    |> Map.new()
  end

  defp boundary(input) do
    {x, y} =
      Enum.map(input, fn {position, _height} ->
        position
      end)
      |> Enum.max()

    %{x: x, y: y}
  end

  defp part1(input) do
    trailheads(input)
    |> Enum.map(&score(input, &1))
    |> Enum.sum()
  end

  defp trailheads(input) do
    Enum.filter(input, fn {_, height} ->
      height == 0
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp score(input, trailhead) do
    1..9
    |> Enum.reduce([trailhead], fn height, positions ->
      positions
      |> Enum.flat_map(&adjacent_positions(&1))
      |> Enum.uniq()
      |> Enum.filter(fn position ->
        Map.get(input, position) == height
      end)
    end)
    |> length()
  end

  defp adjacent_positions({x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  defp part2(input) do
    trailheads(input)
    |> Stream.flat_map(&trails(input, &1))
    |> Enum.count()
  end

  defp rating(trails), do: Enum.count(trails)

  # a position has many feeder trails
  # when a fork at a position occurs, fork each of the feeder trails
  # if any of those feeder positions end up not panning out, cull those 

  defp trails(input, position, height \\ 0)
  defp trails(input, position, 9), do: [position]

  defp trails(input, position, height) do
    adjacent_positions(position)
    |> Stream.flat_map(fn new_position ->
      value_at_position = Map.get(input, new_position)
      valid = value_at_position == height + 1

      if valid do
        trails(input, new_position, height + 1)
      else
        []
      end
    end)
  end
end

Day10.run()
