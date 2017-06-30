defmodule Logger.Backends.Syslog do
  use GenEvent
  use Bitwise

  def init(_) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      {:ok, socket} = :gen_udp.open(0)
      {:ok, configure([socket: socket])}
    else
      {:error, :ignore}
    end
  end

  def handle_call({:configure, options}, _state) do
    {:ok, :ok, configure(options)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    end
    {:ok, state}
  end

  ## Helpers

  defp configure(options) do
    syslog = Keyword.merge(Application.get_env(:logger, :syslog, []), options)
    socket = Keyword.get(options, :socket)
    Application.put_env(:logger, :syslog, syslog)

    format = syslog
      |> Keyword.get(:format)
      |> Logger.Formatter.compile

    level    = Keyword.get(syslog, :level)
    metadata = Keyword.get(syslog, :metadata, [])
    host     = Keyword.get(syslog, :host, '127.0.0.1')
    port     = Keyword.get(syslog, :port, 514)
    facility = Keyword.get(syslog, :facility, :local2) |> Logger.Syslog.Utils.facility
    appid    = Keyword.get(syslog, :appid, :elixir)
    [hostname | _] = String.split("#{:net_adm.localhost()}", ".")
    %{format: format, metadata: metadata, level: level, socket: socket,
      host: host, port: port, facility: facility, appid: appid, hostname: hostname}
  end

  defp log_event(level, msg, ts, md, state) do
    %{format: format, metadata: metadata, facility: facility, appid: appid,
    hostname: _hostname, host: host, port: port, socket: socket} = state

    level_num = Logger.Syslog.Utils.level(level)
    pre = :io_lib.format('<~B>~s ~s~p: ', [facility ||| level_num,
      Logger.Syslog.Utils.iso8601_timestamp(ts), appid, self()])
    packet = [pre, Logger.Formatter.format(format, level, msg, ts, Keyword.take(md, metadata))]
    if socket, do: :gen_udp.send(socket, host, port, packet)
  end
end
