# Syslog

Syslog is an Elixir port of the erlang [Twig](https://github.com/cloudant/twig) 
logger. It is an Elixir logger backend providing UDP support to a syslog server.

## Configuration

### Elixir Project

Syslog's behavior is controlled using the application configuration environment:

* __host__ (127.0.0.1): the hostname of the syslog server
* __port__ (514): the port of the syslog server
* __facility__ (:local2): syslog facility to be used
* __level__ (:info): logging threshold. Messages "above" this threshold (in syslog parlance) will be discarded. Acceptable values are debug, info, notice, warn, err, crit, alert, and emerg.
* __appid__ (:elixir): inserted as the APPID in the syslog message

For example, the following `config/config.exs` file sets up syslog using 
level debug, facility local2, and appid myproj

```
use Mix.Config
config :logger, :syslog, [level: :debug, facility: :local2, appid: "myproj"]
```

### Syslog Server

The syslog server must be configured to support remote logging. On a Redhat based 
Linux distribution, you can setup remote logging by editing `/etc/sysconfig/syslog`
and add the -r option as shown below:

```
# /etc/sysconfig/syslog
...
SYSLOGD_OPTIONS="-m 0 -r"
...
```

The facility also needs to be configured. Again, for Redhat distributions, edit 
`/etc/syslog.conf`, edit the first line below and and add the second:

```
#/etc/syslog.conf
...
*.info;local1.none;mail.none;authpriv.none;cron.none            /var/log/messages
...
local2.*                    /var/log/my_elixir_project.log
```

## License

syslog is copyright (c) 2014 E-MetroTel. 

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
