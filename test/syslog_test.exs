defmodule SyslogTest do
  use ExUnit.Case

  import Logger.Backends.Syslog #, only: [handle_event: 2]

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "handle_event" do
    #{:ok, sock} = :gen_udp.open(5555, [])
    sock = nil
    ts = Logger.Utils.timestamp(false)
    state = %{format: [], metadata: [], facility: 0x10, appid: "test", 
    hostname: nil, host: '127.0.0.1', port: 5555, socket: sock, level_num: 6, level: :info} 
    assert handle_event({:info, nil, {Logger, "test", ts, []}}, state) == {:ok, state}
  end
end
