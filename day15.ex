defmodule Day15 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 10092

    part1(input())
    |> IO.inspect(label: :part1)

    assert part2(example()) == 9021

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day15.txt")
    |> parse()
  end

  defp example() do
    """
    ##########
    #..O..O.O#
    #......O.#
    #.OO..O.O#
    #..O@..O.#
    #O#..O...#
    #O..O..O.#
    #.OO.O.OO#
    #....O...#
    ##########

    <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
    """
    |> parse()
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> then(fn [map, moves] ->
      %{map: parse_map(map), moves: parse_moves(moves)}
    end)
  end

  defp parse_map(mapstring) do
    mapstring
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

  defp parse_moves(movestring) do
    movestring
    |> String.split("")
    |> Enum.filter(fn char -> char in ["^", "<", ">", "v"] end)
    |> Enum.map(fn
      "^" -> :up
      ">" -> :right
      "<" -> :left
      "v" -> :down
    end)
  end

  defp part1(input) do
    {initial_position, _} =
      Enum.find(input.map, fn {_, char} ->
        char == "@"
      end)

    max_position = Enum.max(Map.keys(input.map))

    Enum.reduce(
      input.moves,
      %{map: Map.put(input.map, initial_position, "."), position: initial_position},
      fn move, state ->
        evolve(state, move, max_position)
      end
    )
    |> then(fn state -> state.map end)
    |> Enum.filter(fn {_, char} -> char == "O" end)
    |> Enum.map(fn {{x, y}, _} -> x + 100 * y end)
    |> Enum.sum()
  end

  defp evolve(state, move, boundary) do
    Enum.reduce(positions_in_direction(move, state.position, boundary), {:unknown, []}, fn
      position, {:unknown, box_positions} ->
        case Map.get(state.map, position) do
          "O" -> {:unknown, [position | box_positions]}
          "." -> {:unblocked, box_positions}
          "#" -> :blocked
        end

      _position, other ->
        other
    end)
    |> then(fn
      :blocked ->
        state

      {:unblocked, box_positions} ->
        Enum.reduce(box_positions, state, fn position, state ->
          # take what is in position and put it at up of position
          new_position = Enum.at(positions_in_direction(move, position, boundary), 0)

          %{
            state
            | map:
                state.map
                |> Map.put(new_position, "O")
                |> Map.put(position, ".")
          }
        end)
        |> Map.put(:position, Enum.at(positions_in_direction(move, state.position, boundary), 0))
    end)
  end

  defp positions_in_direction(:up, {_, 0}, _boundary), do: []

  defp positions_in_direction(:up, {x, y}, boundary) do
    [{x, y - 1}] ++ positions_in_direction(:up, {x, y - 1}, boundary)
  end

  defp positions_in_direction(:left, {0, _}, _boundary), do: []

  defp positions_in_direction(:left, {x, y}, boundary) do
    [{x - 1, y}] ++ positions_in_direction(:left, {x - 1, y}, boundary)
  end

  defp positions_in_direction(:right, {x, _}, {x, _}), do: []

  defp positions_in_direction(:right, {x, y}, boundary) do
    [{x + 1, y}] ++ positions_in_direction(:right, {x + 1, y}, boundary)
  end

  defp positions_in_direction(:down, {_, y}, {_, y}), do: []

  defp positions_in_direction(:down, {x, y}, boundary) do
    [{x, y + 1}] ++ positions_in_direction(:down, {x, y + 1}, boundary)
  end

  defp part2(input) do
    input =
      Map.update!(input, :map, fn map ->
        Enum.flat_map(map, fn {{x, y}, char} ->
          {char1, char2} =
            case char do
              "@" -> {"@", "."}
              "O" -> {"[", "]"}
              "#" -> {"#", "#"}
              "." -> {".", "."}
            end

          [{{2 * x, y}, char1}, {{2 * x + 1, y}, char2}]
        end)
        |> Map.new()
      end)

    boundary = Enum.max(Map.keys(input))

    {initial_position, _} =
      Enum.find(input.map, fn {_, char} ->
        char == "@"
      end)

    Enum.reduce(
      input.moves,
      %{map: Map.put(input.map, initial_position, "."), position: initial_position},
      fn move, state ->
        evolve2(state, move, boundary)
      end
    )
    |> then(fn state ->
      state.map
    end)
    |> Enum.filter(fn {_, char} -> char == "[" end)
    |> Enum.map(fn {{x, y}, _} -> x + 100 * y end)
    |> Enum.sum()
  end

  defp evolve2(state, move, boundary) do
    old_state = state

    find_move_disposition(state, move, boundary)
    |> then(fn
      :blocked ->
        state

      {:unblocked, box_positions} ->
        Enum.reduce(Enum.uniq(box_positions), state, fn position, state ->
          new_position = position_in_direction(position, move)

          %{
            state
            | map:
                state.map
                |> Map.put(new_position, Map.get(old_state.map, position))
                |> Map.put(position, ".")
          }
        end)
        |> Map.put(:position, position_in_direction(state.position, move))
    end)
  end

  defp render(state) do
    {max_x, max_y} = Enum.max(Map.keys(state.map))

    Enum.map(0..max_y, fn y ->
      ["\n"] ++
        Enum.map(0..max_x, fn x ->
          if state.position == {x, y} do
            "@"
          else
            Map.get(state.map, {x, y})
          end
        end)
    end)
  end

  defp find_move_disposition(state, move, boundary, acc \\ [])

  defp find_move_disposition(state, move, boundary, acc) do
    new_position = position_in_direction(state.position, move)

    case {move, Map.get(state.map, new_position)} do
      {_, "."} ->
        {:unblocked, acc}

      {direction, "["} when direction in [:left, :right] ->
        find_move_disposition(%{state | position: new_position}, move, boundary, [
          new_position | acc
        ])

      {direction, "]"} when direction in [:left, :right] ->
        find_move_disposition(%{state | position: new_position}, move, boundary, [
          new_position | acc
        ])

      {direction, "["} when direction in [:up, :down] ->
        other_position = position_in_direction(new_position, :right)

        with {:unblocked, left} <-
               find_move_disposition(%{state | position: new_position}, move, boundary),
             {:unblocked, right} <-
               find_move_disposition(%{state | position: other_position}, move, boundary) do
          {:unblocked, left ++ right ++ [new_position, other_position] ++ acc}
        else
          _ -> :blocked
        end

      {direction, "]"} when direction in [:up, :down] ->
        other_position = position_in_direction(new_position, :left)

        with {:unblocked, right} <-
               find_move_disposition(%{state | position: new_position}, move, boundary),
             {:unblocked, left} <-
               find_move_disposition(%{state | position: other_position}, move, boundary) do
          {:unblocked, left ++ right ++ [new_position, other_position] ++ acc}
        else
          _ -> :blocked
        end

      {_, "#"} ->
        :blocked
    end
  end

  defp position_in_direction({x, y}, :up) do
    {x, y - 1}
  end

  defp position_in_direction({x, y}, :down) do
    {x, y + 1}
  end

  defp position_in_direction({x, y}, :left) do
    {x - 1, y}
  end

  defp position_in_direction({x, y}, :right) do
    {x + 1, y}
  end
end

Day15.run()
