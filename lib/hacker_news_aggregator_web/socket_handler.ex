defmodule HackerNewsAggregatorWeb.SocketHandler do
  @behaviour :cowboy_websocket

  alias HackerNewsAggregator.State

  # Wait the double before going down
  @timeout 2 * State.get_countdown()

  def init(request, _state) do
    state = %{key: get_registry_key()}

    {:cowboy_websocket, request, state, %{idle_timeout: @timeout}}
  end

  def websocket_init(state) do
    Registry.HackerNewsAggregator
    |> Registry.register(state.key, {})

    {:ok, state}
  end

  @doc """
  What ever the client sent, we answer the same text
  """
  def websocket_handle({:text, json}, state) do
    {:reply, {:text, json}, state}
  end

  @doc """
  Receive top stories from GenServer and send them to the client
  """
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
