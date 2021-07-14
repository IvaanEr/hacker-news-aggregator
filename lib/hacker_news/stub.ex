defmodule HackerNews.Stub do
  @moduledoc """
  Hacker News API Stubs for testing
  """

  @behaviour HackerNews.API

  # TODO The Stub should be something more complete and test every field
  # in the story
  @impl true
  def top_stories(_config) do
    {:ok, [1234, 5678, 9012]}
  end

  @impl true
  def get_item(_config, id) do
    {:ok, %{"id" => id}}
  end
end
