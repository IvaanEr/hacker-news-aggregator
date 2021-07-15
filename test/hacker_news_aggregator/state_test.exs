defmodule HackerNewsAggregator.StateTest do
  use ExUnit.Case
  alias HackerNewsAggregator.State
  alias HackerNewsAggregator.TopStories

  test "start_link/1" do
    pid = start_supervised!(State, start: {State, :start_link, [:state_test]})
    assert ^pid = Process.whereis(:state_test)
  end

  test "GenServer start fetching stories" do
    start_supervised!(State, start: {State, :start_link, [:state_test]})
    :timer.sleep(500)

    assert :state_test |> State.get_top_stories() |> length() == 3
  end

  test "fetch top stories from HackerNews" do
    assert {:noreply, %TopStories{top_stories_ids: [1234, 5678, 9012]}} =
             State.handle_info(:fetch_top_stories, %TopStories{})
  end

  test "fetch items from HackerNews" do
    state = %TopStories{top_stories_ids: [123, 456]}

    assert {:noreply, %TopStories{top_stories: [%{"id" => 123}, %{"id" => 456}]}} =
             State.handle_info(:fetch_items, state)
  end

  test "get top stories from state" do
    top_stories = [%{"id" => 123}]
    state = %TopStories{top_stories: top_stories}

    assert {:reply, ^top_stories, ^state} = State.handle_call(:get_top_stories, self(), state)
  end

  test "get top story from state" do
    top_story = %{"id" => 123}
    state = %TopStories{top_stories: [top_story]}

    assert {:reply, {:ok, ^top_story}, ^state} =
             State.handle_call({:get_top_story, 123}, self(), state)
  end

  test "get top story from HackerNews" do
    top_story = %{"id" => 123}
    state = %TopStories{}

    assert {:reply, {:ok, ^top_story}, ^state} =
             State.handle_call({:get_top_story, 123}, self(), state)
  end
end
