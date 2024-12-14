defmodule Day13 do
  import ExUnit.Assertions

  def run() do
    assert part1(example()) == 480

    part1(input())
    |> IO.inspect(label: :part1)

    part2(input())
    |> IO.inspect(label: :part2)
  end

  defp input() do
    File.read!("day13.txt")
    |> parse()
  end

  defp example() do
    """
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400

    Button A: X+26, Y+66
    Button B: X+67, Y+21
    Prize: X=12748, Y=12176

    Button A: X+17, Y+86
    Button B: X+84, Y+37
    Prize: X=7870, Y=6450

    Button A: X+69, Y+23
    Button B: X+27, Y+71
    Prize: X=18641, Y=10279
    """
    |> parse()
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn group ->
      [_, a_x, a_y, b_x, b_y, prize_x, prize_y] =
        Regex.run(
          ~r/Button A: X\+(.*), Y\+(.*)\nButton B: X\+(.*), Y\+(.*)\nPrize: X=(.*), Y=(.*)$/,
          String.trim(group)
        )

      %{
        a: {String.to_integer(a_x), String.to_integer(a_y)},
        b: {String.to_integer(b_x), String.to_integer(b_y)},
        prize: {String.to_integer(prize_x), String.to_integer(prize_y)}
      }
    end)
  end

  defp part1(input) do
    # a * c1 + b * c3 = x
    # a * c2 + b * c4 = y
    # a = (x - b * c3) / c1
    # a = (y - b * c4) / c2
    # (x - b * c3) / c1 = (y - b * c4) / c2
    # c2 * (x - b * c3) = c1 * (y - b * c4)
    # c2 * x - b * c3 * c2 = c1 * y - b * c1 * c4
    # c2 * x - c1 * y = b * c3 * c2 - b * c1 * c4 
    # c2 * x - c1 * y = b * (c3 * c2 - c1 * c4)
    # c2 * x - c1 * y = b * (c3 * c2 - c1 * c4)
    # b = (c2 * x - c1 * y) / (c3 * c2 - c1 * c4)
    input
    |> Enum.map(fn %{a: {c1, c2}, b: {c3, c4}, prize: {x, y}} ->
      b = div(c2 * x - c1 * y, c3 * c2 - c1 * c4)
      divisible = rem(c2 * x - c1 * y, c3 * c2 - c1 * c4) == 0
      a = div(x - b * c3, c1)
      {a, b, divisible}
    end)
    |> Enum.filter(fn {_, _, divisible} -> divisible end)
    |> Enum.map(fn {a, b, _} -> 3 * a + b end)
    |> Enum.sum()
  end

  defp part2(input) do
    input
    |> Enum.map(fn %{prize: {x, y}} = machine ->
      %{machine | prize: {x + 10_000_000_000_000, y + 10_000_000_000_000}}
    end)
    |> part1()
  end
end

Day13.run()
