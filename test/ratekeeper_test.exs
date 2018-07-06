defmodule RatekeeperTest do
  use ExUnit.Case
  doctest Ratekeeper

  @int1 1000
  @lim1 2
  @int2 3000
  @lim2 4
  test "two limits" do
    Ratekeeper.add_limit :a, @int1, @lim1
    Ratekeeper.add_limit :a, @int2, @lim2
    delays = Enum.map(1..200, fn _ -> Ratekeeper.register(:a, 160000) end)

    assert Enum.sort(delays) == delays
    assert [] ==
      delays
      |> Enum.chunk_every(@lim1 + 1, 1, :discard)
      |> Enum.filter(fn chunk -> Enum.at(chunk, -1) - Enum.at(chunk, 0) < @int1 end)

    assert [] ==
      delays
      |> Enum.chunk_every(@lim2 + 1, 1, :discard)
      |> Enum.filter(fn chunk -> Enum.at(chunk, -1) - Enum.at(chunk, 0) < @int2 end)
  end

  test "max_waiting_time" do
    Ratekeeper.add_limit :b, 3000, 3
    delays = Enum.map(1..9, fn _ -> Ratekeeper.register(:b, 6000) end)

    assert Enum.slice(delays, 0..5) ==
      Enum.filter(delays, fn x -> x != nil end)
  end
end
