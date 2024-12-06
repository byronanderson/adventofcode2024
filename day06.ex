defmodule Day06 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day06.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.split(line, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, char}
      end)
    end)
    |> Map.new()
  end

  defp part1(input) do
    {{max_x, max_y}, _} = Enum.max_by(input, fn {position, _} -> position end)
    {starting_location, _} = Enum.find(input, fn {_, char} -> char == "^" end)
    input = Map.put(input, starting_location, ".")

    stream(
      input,
      {starting_location, :up},
      {0, 0, max_x, max_y}
    )
    |> Stream.map(fn {position, _orientation} -> position end)
    |> Enum.into(MapSet.new([starting_location]))
    |> MapSet.size()
  end

  defp stream(map, initial_position, boundary) do
    Stream.unfold(initial_position, fn position ->
      acc = travel(map, position, boundary)

      if acc do
        {acc, acc}
      else
        nil
      end
    end)
  end

  defp travel(_, {{x, _}, _}, {min_x, _, _, _}) when x < min_x, do: nil
  defp travel(_, {{x, _}, _}, {_, _, max_x, _}) when x > max_x, do: nil
  defp travel(_, {{_, y}, _}, {_, min_y, _, _}) when y < min_y, do: nil
  defp travel(_, {{_, y}, _}, {_, _, _, max_y}) when y > max_y, do: nil

  defp travel(map, {{x, y}, orientation}, _boundary) do
    move({x, y}, orientation)
    |> then(fn candidate_location ->
      case Map.get(map, candidate_location) do
        "#" -> {{x, y}, turn_right(orientation)}
        _ -> {candidate_location, orientation}
      end
    end)
  end

  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}
  defp move({x, y}, :right), do: {x + 1, y}

  defp turn_right(:up), do: :right
  defp turn_right(:right), do: :down
  defp turn_right(:down), do: :left
  defp turn_right(:left), do: :up

  defp part2(input) do
    {{max_x, max_y}, _} = Enum.max_by(input, fn {position, _} -> position end)
    {starting_location, _} = Enum.find(input, fn {_, char} -> char == "^" end)
    input = Map.put(input, starting_location, ".")

    for {position, char} <- input,
        char == ".",
        reduce: [] do
      acc ->
        if infinite?(
             Map.put(input, position, "#"),
             {starting_location, :up},
             {0, 0, max_x, max_y}
           ) do
          [position | acc]
        else
          acc
        end
    end
    |> length()
  end

  defp infinite?(map, state, boundary) do
    stream(map, state, boundary)
    |> Stream.transform(MapSet.new([state]), fn state, states ->
      if MapSet.member?(states, state) do
        {[:infinite], states}
      else
        {[], MapSet.put(states, state)}
      end
    end)
    |> Enum.take(1)
    |> List.first()
    |> then(fn el -> el == :infinite end)
  end
end

Day06.run()
