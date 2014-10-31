alias Logger.Syslog.Utils
defmodule Utils.TimestampTest do
  use ExUnit.Case

  import Utils, only: [iso8601_timestamp: 1]

  test "timestamp format" do
    ts = Logger.Utils.timestamp(false)
    s = iso8601_timestamp(ts)
    assert String.length(s) == 15
    [mon, day, hms] = String.split(s)
    [h, m, s] = String.split(hms, ":")
    assert mon =~ ~r/^[A-Z][a-z][a-z]$/
    for x <- [h, m, s, day], do:
      assert x =~ ~r/^\d\d$/
    [h, m, s, day] = for x <- [h, m, s, day], do:
      Integer.parse(x) |> elem(0)
    assert day >= 1
    assert day <= 31
    assert h >= 0
    assert h <= 23
    assert m >= 0
    assert m <= 59
    assert s >= 0
    assert s <= 59
  end
end
