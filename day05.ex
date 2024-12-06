defmodule Day05 do
  def run() do
    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    sample = """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    97,13,75,29,47
    61,13,29
    """

    File.read!("day05.txt")
    |> String.split("\n\n", trim: true)
    |> then(fn [page_ordering_rules, updates] ->
      {String.split(page_ordering_rules, "\n", trim: true)
       |> Enum.map(fn line ->
         [ancestor, descendant] = String.split(line, "|") |> Enum.map(&String.to_integer/1)
         [ancestor: ancestor, descendant: descendant]
       end)
       |> Enum.group_by(fn x -> x[:descendant] end),
       String.split(updates, "\n", trim: true)
       |> Enum.map(fn line ->
         String.split(line, ",", trim: true)
         |> Enum.map(&String.to_integer/1)
       end)}
    end)
  end

  defp part1({rules, updates}) do
    updates
    |> Enum.filter(&in_order?(&1, rules))
    |> Enum.map(&middle_page_number/1)
    |> Enum.sum()
  end

  defp in_order?(update, rules) do
    first_misorder(update, rules) == nil
  end

  defp first_misorder(update, rules) do
    update
    |> with_descendants()
    |> Stream.flat_map(fn {el, descendants} ->
      Map.get(rules, el, [])
      |> Enum.filter(fn rule ->
        Enum.find(descendants, fn x -> x == rule[:ancestor] end)
      end)
    end)
    |> Enum.at(0)
  end

  defp with_descendants(list) do
    Stream.unfold(list, fn
      [] -> nil
      [head | tail] -> {{head, tail}, tail}
    end)
  end

  defp middle_page_number(list) do
    Enum.at(list, div(length(list), 2))
  end

  defp part2({rules, updates}) do
    updates
    |> Enum.reject(&in_order?(&1, rules))
    |> Enum.map(fn update ->
      find_correct_order(update, rules)
    end)
    |> Enum.map(&middle_page_number/1)
    |> Enum.sum()
  end

  defp find_correct_order(update, rules) do
    case first_misorder(update, rules) do
      nil -> update
      misorder -> find_correct_order(fixup(update, misorder), rules)
    end
  end

  defp fixup(update, misorder) do
    ancestor_index = Enum.find_index(update, fn x -> x == misorder[:descendant] end)
    update = List.delete_at(update, ancestor_index)
    descendant = Enum.find_index(update, fn x -> x == misorder[:ancestor] end)
    List.insert_at(update, descendant + 1, misorder[:descendant])
  end
end

Day05.run()
