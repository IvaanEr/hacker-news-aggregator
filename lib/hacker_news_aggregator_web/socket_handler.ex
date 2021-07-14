defmodule HackerNewsAggregatorWeb.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{key: get_registry_key()}

    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.HackerNewsAggregator
    |> Registry.register(state.key, {})

    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    # Return the text sent by client.
    {:reply, {:text, json}, state}
  end

  def websocket_info({:top_stories, top_stories}, state) do
    message = Jason.encode!(top_stories)
    {:reply, {:text, message}, state}
  end

  def get_registry_key do
    :hacker_news_aggregator
    |> Application.get_env(__MODULE__)
    |> Keyword.get(:registry_key, :hacker_news_ws)
  end
end
