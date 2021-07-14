defmodule HackerNewsAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HackerNewsAggregatorWeb.Router,
        options: [dispatch: dispatch(), port: 4001]
      ),
      # :duplicate is used to register all the websockets under the same key,
      # it is easier to get all the websocket pids this way.
      Registry.child_spec(keys: :duplicate, name: Registry.HackerNewsAggregator),
      HackerNewsAggregator.State
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HackerNewsAggregator]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", HackerNewsAggregatorWeb.SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {HackerNewsAggregatorWeb.Router, []}}
       ]}
    ]
  end
end
