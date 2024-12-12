defmodule Day12 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 1930

    part1(input())
    |> IO.inspect(label: :part1)

    assert part2(example()) == 1206

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day12.txt")
    |> parse()
  end

  defp example() do
    """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
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
    find_regions(input)
    |> Enum.map(fn region ->
      perimeter(input, region) * area(input, region)
    end)
    |> Enum.sum()
  end

  defp perimeter(input, region) do
    region
    |> Enum.map(&sides_exposed(input, &1))
    |> Enum.sum()
  end

  defp sides_exposed(input, location) do
    crop = Map.get(input, location)

    [up(location), left(location), right(location), down(location)]
    |> Enum.reject(fn location -> Map.get(input, location) == crop end)
    |> length()
  end

  defp area(_input, region) do
    length(region)
  end

  defp up({x, y}), do: {x, y + 1}
  defp down({x, y}), do: {x, y - 1}
  defp left({x, y}), do: {x - 1, y}
  defp right({x, y}), do: {x + 1, y}

  defp find_regions(input) do
    Stream.unfold(MapSet.new(Map.keys(input)), fn unfound ->
      to_find = Enum.at(unfound, 0)

      case to_find do
        nil ->
          nil

        _ ->
          {region, unfound} = find_region(input, to_find, unfound)
          {Enum.uniq(region), unfound}
      end
    end)
  end

  defp find_region(input, location, unfound) do
    crop = Map.fetch!(input, location)
    unfound = unfound |> MapSet.delete(location)

    {region, unfound} =
      [up(location), left(location), right(location), down(location)]
      |> Enum.flat_map_reduce(unfound, fn location, unfound ->
        if Map.get(input, location) == crop and MapSet.member?(unfound, location) do
          unfound = unfound |> MapSet.delete(location)
          {subregion, unfound} = find_region(input, location, unfound)
          {[location] ++ subregion, unfound}
        else
          {[], unfound}
        end
      end)

    {[location | region], unfound}
  end

  defp number_of_sides(input, region) do
    region
    |> Enum.flat_map_reduce(MapSet.new(), fn location, considered_sides ->
      {top_sides, considered_sides} = consider(input, {:top, location}, considered_sides)
      {bottom_sides, considered_sides} = consider(input, {:bottom, location}, considered_sides)
      {left_sides, considered_sides} = consider(input, {:left, location}, considered_sides)
      {right_sides, considered_sides} = consider(input, {:right, location}, considered_sides)
      {top_sides ++ bottom_sides ++ left_sides ++ right_sides, considered_sides}
    end)
    |> elem(0)
    |> length()
  end

  defp consider(input, side_of_location, already_considered_sides) do
    with false <- MapSet.member?(already_considered_sides, side_of_location),
         true <- fence_present?(input, side_of_location) do
      side = build_side(input, side_of_location)
      {[side], MapSet.union(already_considered_sides, MapSet.new(side))}
    else
      _ -> {[], already_considered_sides}
    end
  end

  defp build_side(input, side_of_location) do
    [side_of_location] ++
      expand(input, side_of_location, :negative) ++
      expand(input, side_of_location, :positive)
  end

  defp expand(input, {side, location}, direction) do
    crop = Map.get(input, location)

    progress = fn location ->
      case {side, direction} do
        {:top, :negative} -> left(location)
        {:top, :positive} -> right(location)
        {:bottom, :negative} -> left(location)
        {:bottom, :positive} -> right(location)
        {:left, :negative} -> up(location)
        {:left, :positive} -> down(location)
        {:right, :negative} -> up(location)
        {:right, :positive} -> down(location)
      end
    end

    Stream.unfold(progress.(location), fn location ->
      if Map.get(input, location) == crop and fence_present?(input, {side, location}) do
        {{side, location}, progress.(location)}
      else
        nil
      end
    end)
    |> Enum.to_list()
  end

  defp fence_present?(input, {_, location} = side_of_location) do
    other_side =
      case side_of_location do
        {:top, location} -> up(location)
        {:bottom, location} -> down(location)
        {:right, location} -> right(location)
        {:left, location} -> left(location)
      end

    Map.get(input, location) != Map.get(input, other_side)
  end

  defp part2(input) do
    find_regions(input)
    |> Enum.map(fn region ->
      number_of_sides(input, region) * area(input, region)
    end)
    |> Enum.sum()
  end
end

Day12.run()
