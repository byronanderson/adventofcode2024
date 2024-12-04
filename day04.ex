defmodule Day04 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day04.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.split(line, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {<<char>>, x} ->
        {{x, y}, char}
      end)
    end)
    |> Enum.into(%{})
  end

  defp part1(input) do
    # strategy: check every X, see how many times that x makes xmas up, down, left, right, and diagonals
    input
    |> Enum.filter(fn {_, char} -> char == ?X end)
    |> Enum.map(fn {location, _} ->
      xmas(input, location, {1, 1}) + xmas(input, location, {1, 0}) +
        xmas(input, location, {1, -1}) + xmas(input, location, {0, -1}) +
        xmas(input, location, {-1, -1}) + xmas(input, location, {-1, 0}) +
        xmas(input, location, {-1, 1}) + xmas(input, location, {0, 1})
    end)
    |> Enum.sum()
  end

  defp xmas?(input, {x, y}, {x_offset, y_offset} = _direction) do
    Map.get(input, {x, y}) == ?X and
      Map.get(input, {x + x_offset, y + y_offset}) == ?M and
      Map.get(input, {x + 2 * x_offset, y + 2 * y_offset}) == ?A and
      Map.get(input, {x + 3 * x_offset, y + 3 * y_offset}) == ?S
  end

  defp xmas(input, location, offset) do
    if xmas?(input, location, offset) do
      1
    else
      0
    end
  end

  defp part2(input) do
    # strategy: check every A, see if any of the directions make it an X-MAS
    input
    |> Enum.filter(fn {_, char} -> char == ?A end)
    |> Enum.filter(fn {location, _} ->
      x_mas?(input, location)
    end)
    |> Enum.count()
  end

  defp x_mas?(input, {x, y}) do
    Map.get(input, {x, y}) == ?A and
      crossy(input, {x, y})
  end

  defp crossy(input, {x, y}) do
    [
      Map.get(input, {x - 1, y - 1}),
      Map.get(input, {x + 1, y - 1}),
      Map.get(input, {x + 1, y + 1}),
      Map.get(input, {x - 1, y + 1})
    ] in [
      [?M, ?M, ?S, ?S],
      [?S, ?M, ?M, ?S],
      [?S, ?S, ?M, ?M],
      [?M, ?S, ?S, ?M]
    ]
  end
end

Day04.run()
