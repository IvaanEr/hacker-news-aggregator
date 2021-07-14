defmodule HackerNewsAggregator.State do
  @moduledoc """
  This module handle the state of the application.
  - Every 5 minutes fetch top stories from HackerNews
  - Fetch the entire story from the IDs previously fetch
  - API to get the top stories stored
  - API to get a single story store or fetch it from HackerNews if it isn't present
    in the state
  """
  use GenServer, start: {__MODULE__, :start_link, []}

  alias HackerNewsAggregator.TopStories
  alias HackerNews.API

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
        # TODO: Handle errors
        {:ok, story} = API.get_item(API.new(), id)
        {:reply, story, state}

      story ->
        {:reply, story, state}
    end
  end

  @impl true
  def handle_info(:fetch_top_stories, top_stories) do
    Logger.info("Fetching top stories")
    {:ok, top_stories_ids} = API.top_stories(API.new())

    Process.send_after(self(), :fetch_top_stories, :timer.minutes(5))
    Process.send_after(self(), :fetch_items, 100)
    {:noreply, Map.put(top_stories, :top_stories_ids, top_stories_ids)}
  end

  @impl true
  def handle_info(:fetch_items, %TopStories{top_stories_ids: ids} = top_stories) do
    items = Enum.map(ids, &fetch_item/1)
    {:noreply, Map.put(top_stories, :top_stories, items)}
  end

  defp fetch_item(id) do
    {:ok, item} = API.get_item(API.new(), id)
    item
  end
end
