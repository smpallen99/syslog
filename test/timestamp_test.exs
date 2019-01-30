alias Logger.Syslog.Utils
defmodule Utils.TimestampTest do
  use ExUnit.Case

  import Utils, only: [iso8601_timestamp: 1]

  test "timestamp format" do
    ts = Logger.Utils.timestamp(false)
    s = iso8601_timestamp(ts)
    {:ok, regex} = Regex.compile("(?<year>\\d{4})-" <>
      "(?<month>\\d{2})-" <>
      "(?<day>\\d{2})" <>
      "T" <>
      "(?<hours>\\d{2})" <>
      ":" <>
      "(?<minutes>\\d{2})" <>
      ":" <>
      "(?<seconds>\\d{2})" <>
      "\." <>
      "(?<fraction>\\d+)" <>
      "Z"
    )
    matches = Regex.named_captures(regex, s)
    t = Map.new(matches, fn {k, v} ->
      {i, ""} = Integer.parse(v)
      {String.to_atom(k), i}
    end)

    assert t.year >= 0
    assert t.month >= 1 and t.month <= 31
    assert t.day >= 1 and t.day <= 31
    assert t.hours >= 0 and t.hours <= 23
    assert t.minutes >= 0 and t.minutes <= 59
    assert t.seconds >= 0 and t.seconds <= 59
    assert t.fraction >= 0
  end
end
