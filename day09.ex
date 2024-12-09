defmodule Day09 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 1928

    part1(input())
    |> IO.inspect(label: :part1)

    assert part2(example()) == 2858

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day09.txt")
    |> parse()
  end

  defp example() do
    """
    2333133121414131402
    """
    |> parse()
  end

  defp parse(input) do
    Stream.unfold(String.trim(input), fn
      <<char, rest::binary>> -> {String.to_integer(<<char>>), rest}
      "" -> nil
    end)
  end

  defp part1(input) do
    input
    |> to_memory()
    |> compact()
    |> checksum()
  end

  defp to_memory(stream) do
    stream
    |> Stream.transform({0, :fill}, fn
      size, {id, :fill} ->
        {1..size//1 |> Enum.map(fn _ -> id end), {id + 1, :empty}}

      size, {id, :empty} ->
        {1..size//1 |> Enum.map(fn _ -> :empty end), {id, :fill}}
    end)
    |> Stream.with_index()
    |> Enum.reduce(%{filled: %{}, empty: [], filled_positions: []}, fn
      {:empty, i}, acc ->
        %{acc | empty: [i | acc.empty]}

      {id, i}, acc ->
        %{acc | filled: Map.put(acc.filled, i, id), filled_positions: [i | acc.filled_positions]}
    end)
    |> then(fn x -> %{x | empty: Enum.reverse(x.empty)} end)
  end

  defp compact(data) do
    Stream.zip(data.filled_positions, data.empty)
    |> Enum.reduce(data.filled, fn {filled_position, empty_position}, acc ->
      if empty_position < filled_position do
        acc
        |> Map.put(empty_position, Map.fetch!(acc, filled_position))
        |> Map.delete(filled_position)
      else
        acc
      end
    end)
  end

  defp checksum(memory) do
    memory
    |> Stream.map(fn {index, id} -> index * id end)
    |> Enum.sum()
  end

  defp part2(input) do
    input
    |> to_memory2()
    |> compact2()
    |> checksum2()
  end

  defp to_memory2(stream) do
    stream
    |> Stream.transform({0, :fill}, fn
      size, {id, :fill} ->
        {[{:filled, id, size}], {id + 1, :empty}}

      size, {id, :empty} ->
        {[{:empty, size}], {id, :fill}}
    end)
    |> Enum.reduce({%{filled: [], empty: []}, 0}, fn
      {:empty, 0}, acc ->
        acc

      {:empty, size}, {state, index} ->
        {%{state | empty: [index..(index + size - 1) | state.empty]}, index + size}

      {:filled, _, 0}, acc ->
        acc

      {:filled, id, size}, {state, index} ->
        {%{state | filled: [{id, index..(index + size - 1)} | state.filled]}, index + size}
    end)
    |> then(fn {state, _} -> %{state | empty: Enum.reverse(state.empty)} end)
  end

  defp compact2(state) do
    state.filled
    |> Enum.reduce(state, fn {id, range} = filling, state ->
      found_empty_slot =
        Enum.find(state.empty, fn slot ->
          slot.first < range.first and Range.size(slot) >= Range.size(range)
        end)

      case found_empty_slot do
        nil ->
          state

        empty_slot ->
          state
          |> Map.update!(:filled, fn filled ->
            filled
            |> Enum.map(fn
              ^filling -> {id, empty_slot.first..(empty_slot.first + Range.size(range) - 1)}
              other -> other
            end)
          end)
          |> reduce_empty_slot_size(empty_slot, Range.size(range))
      end
    end)
  end

  defp reduce_empty_slot_size(state, empty_slot, reduction_amount) do
    if Range.size(empty_slot) == reduction_amount do
      %{state | empty: List.delete(state.empty, empty_slot)}
    else
      %{
        state
        | empty:
            Enum.map(state.empty, fn
              ^empty_slot -> (empty_slot.first + reduction_amount)..empty_slot.last
              other -> other
            end)
      }
    end
  end

  defp checksum2(memory) do
    memory.filled
    |> Stream.flat_map(fn {id, range} -> Enum.map(range, fn i -> {i, id} end) end)
    |> Stream.map(fn {index, id} -> index * id end)
    |> Enum.sum()
  end
end

Day09.run()
