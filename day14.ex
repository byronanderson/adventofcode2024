defmodule Day14 do
  import ExUnit.Assertions

  def run() do
    assert part1(example(), {11, 7}) == 12

    part1(input(), {101, 103})
    |> IO.inspect(label: :part1)

    part2(input(), {101, 103})
    |> IO.inspect(label: :part2)
    |> then(fn position ->
      1..position
      |> Enum.reduce(input(), fn _, state ->
        evolve(state, {101, 103})
      end)
      |> render({101, 103})
      |> IO.puts()
    end)
  end

  defp input() do
    File.read!("day14.txt")
    |> parse()
  end

  defp example() do
    """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
    |> parse()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, px, py, vx, vy] = Regex.run(~r/^p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)$/, line)

      %{
        position: {String.to_integer(px), String.to_integer(py)},
        velocity: {String.to_integer(vx), String.to_integer(vy)}
      }
    end)
  end

  defp part1(input, boundary) do
    1..100
    |> Enum.reduce(input, fn _, state ->
      evolve(state, boundary)
    end)
    |> score(boundary)
  end

  defp evolve(state, {max_x, max_y}) do
    state
    |> Enum.map(fn %{position: {x, y}, velocity: {vx, vy}} = robot ->
      %{
        robot
        | position: {max(rem(x + vx + max_x, max_x), 0), max(rem(y + vy + max_y, max_y), 0)}
      }
    end)
  end

  defp score(state, boundary) do
    inc = fn x -> x + 1 end

    Enum.reduce(state, [0, 0, 0, 0], fn robot, acc ->
      case quadrant(robot, boundary) do
        nil -> acc
        q -> List.update_at(acc, q, inc)
      end
    end)
    |> Enum.product()
  end

  defp quadrant(%{position: {x, y}}, {max_x, max_y}) do
    case {half(x, max_x), half(y, max_y)} do
      {:lower, :lower} -> 0
      {:lower, :upper} -> 1
      {:upper, :lower} -> 2
      {:upper, :upper} -> 3
      _other -> nil
    end
  end

  defp half(position, upper) do
    midpoint = div(upper, 2)

    cond do
      position < midpoint -> :lower
      position > midpoint -> :upper
      position == midpoint -> :mid
    end
  end

  defp part2(input, boundary) do
    Stream.unfold(input, fn state ->
      {state, evolve(state, boundary)}
    end)
    |> Enum.find_index(fn state ->
      proportion_of_robots_in_tree_shape(state, boundary) > 0.5
    end)
  end

  defp render(state, {max_x, max_y}) do
    positions_filled =
      state
      |> Enum.map(fn x -> x.position end)
      |> MapSet.new()

    Enum.map(0..(max_y - 1), fn y ->
      ["\n"] ++
        Enum.map(0..(max_x - 1), fn x ->
          if MapSet.member?(positions_filled, {x, y}) do
            "*"
          else
            " "
          end
        end)
    end)
    |> IO.puts()
  end

  defp proportion_of_robots_in_tree_shape(state, {max_x, _} = _boundary) do
    positions_filled =
      state
      |> Enum.map(fn x -> x.position end)
      |> MapSet.new()

    # I thought they would sorta draw the outer edge of the tree.
    # turns out they sorta just clump together,
    # but I got lucky and this algorithm approximated a density check
    # totally fine

    in_tree_shape? = fn %{position: {x, y}} ->
      MapSet.member?(positions_filled, {x + 1, y + 1}) or
        MapSet.member?(positions_filled, {x + 1, y - 1}) or
        MapSet.member?(positions_filled, {x - 1, y - 1}) or
        MapSet.member?(positions_filled, {x - 1, y + 1})
    end

    count_in_tree_shape =
      state
      |> Enum.filter(in_tree_shape?)
      |> Enum.count()

    Enum.count(state)

    count_in_tree_shape / Enum.count(state)
  end
end

Day14.run()
