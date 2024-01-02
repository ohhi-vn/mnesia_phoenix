# Mnesia real-time distributed database on clustering Elixir nodes
## Guide

To start app:

In case you are binding by other IP please change app config and commands.

* Terminal 1:
  `PORT=4000 iex --sname a@localhost --cookie abc -S mix phx.server`
* Terminal 2:
  `PORT=4001 iex --sname b@localhost --cookie abc -S mix phx.server`

Note: If you use Windows please run set PORT=4001 to set environment variable. Similar for other instance.