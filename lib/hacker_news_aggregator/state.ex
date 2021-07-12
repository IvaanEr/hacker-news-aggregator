defmodule HackerNewsAggregator.State do
  @moduledoc """

  """
  use GenServer

  alias HackerNewsAggregator.TopStories
  alias HackerNews.API

  require Logger

  def start_link(_default) do
    Logger.info("#{__MODULE__} started")
    GenServer.start_link(__MODULE__, %TopStories{})
  end

  def get_top_stories() do
    GenServer.call(__MODULE__, :get_top_stories)
  end

  def get_top_story(id) do
    GenServer.call(__MODULE__, {:get_top_story, id})
  end

  @impl true
  def init(%TopStories{} = top_stories) do
    send(self(), :fetch_top_stories)
    {:ok, top_stories}
  end

  @impl true
  def handle_call(:get_top_stories, _from, %TopStories{top_stories: top_stories} = state) do
    {:reply, top_stories, state}
  end

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

  def handle_info(:fetch_items, %TopStories{top_stories_ids: ids} = top_stories) do
    items = Enum.map(ids, &fetch_item/1)
    {:noreply, Map.put(top_stories, :top_stories, items)}
  end

  defp fetch_item(id) do
    {:ok, item} = API.get_item(API.new(), id)
    item
  end
end
