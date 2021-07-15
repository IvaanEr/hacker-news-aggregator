defmodule HackerNewsAggregator.State do
  @moduledoc """
  This module handle the state of the application.
  - Every 5 minutes fetch top stories from HackerNews
  - Fetch the entire story from the IDs previously fetch
  - API to get the top stories stored
  - API to get a single story store or fetch it from HackerNews if it isn't present
    in the state
  - Send top stories to every websocket connection
  """
  use GenServer, start: {__MODULE__, :start_link, []}

  alias HackerNewsAggregator.TopStories
  alias HackerNews.API
  alias HackerNewsAggregatorWeb.SocketHandler

  require Logger

  # -----------
  #   Client
  # -----------
  def start_link(name \\ __MODULE__) do
    Logger.info("#{__MODULE__} started")
    GenServer.start_link(__MODULE__, %TopStories{}, name: name)
  end

  def get_top_stories(pid \\ __MODULE__) do
    GenServer.call(pid, :get_top_stories)
  end

  def get_top_story(pid \\ __MODULE__, id) do
    GenServer.call(pid, {:get_top_story, id})
  end

  # -----------
  #   Server
  # -----------
  @impl true
  def init(%TopStories{} = top_stories) do
    send(self(), :fetch_top_stories)
    {:ok, top_stories}
  end

  @impl true
  def handle_call(:get_top_stories, _from, %TopStories{top_stories: top_stories} = state) do
    {:reply, top_stories, state}
  end

  @impl true
  def handle_call({:get_top_story, id}, _from, %TopStories{top_stories: top_stories} = state) do
    case Enum.find(top_stories, fn story -> story["id"] == id end) do
      nil ->
        case API.get_item(API.new(), id) do
          {:ok, nil} ->
            {:reply, {:error, :notfound}, state}

          {:ok, story} ->
            {:reply, {:ok, story}, state}

          {:error, _, _, response} ->
            {:reply, {:error, response}, state}

          {:error, _, reason} ->
            {:reply, {:error, reason}, state}
        end

      story ->
        {:reply, {:ok, story}, state}
    end
  end

  @impl true
  def handle_info(:fetch_top_stories, top_stories) do
    Logger.info("Fetching top stories")
    {:ok, top_stories_ids} = API.top_stories(API.new())

    Process.send_after(self(), :fetch_top_stories, get_countdown())
    # TODO: Improve this to avoid race conditions
    Process.send_after(self(), :fetch_items, 100)
    {:noreply, Map.put(top_stories, :top_stories_ids, top_stories_ids)}
  end

  @impl true
  def handle_info(:fetch_items, %TopStories{top_stories_ids: ids} = top_stories) do
    items = Enum.map(ids, &fetch_item/1)
    send(self(), :do_web_socket)
    {:noreply, Map.put(top_stories, :top_stories, items)}
  end

  @impl true
  @doc """
  Send the updated top stories to every web socket connection in the Registry.HackerNewsAggregator
  under the key from config
  """
  def handle_info(:do_web_socket, %TopStories{top_stories: top_stories} = state) do
    case Registry.lookup(Registry.HackerNewsAggregator, SocketHandler.get_registry_key()) do
      [] ->
        :ok

      _ ->
        Registry.dispatch(
          Registry.HackerNewsAggregator,
          :hacker_news_ws,
          &Enum.each(&1, fn {pid, _} ->
            send(pid, {:top_stories, top_stories})
          end)
        )

        :ok
    end

    {:noreply, state}
  end

  defp fetch_item(id) do
    {:ok, item} = API.get_item(API.new(), id)
    item
  end

  def get_countdown do
    :hacker_news_aggregator
    |> Application.get_env(__MODULE__)
    |> Keyword.get(:count_down, :timer.minutes(5))
  end
end
