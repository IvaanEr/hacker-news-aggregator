defmodule HackerNews.Stub do
  @moduledoc """
  Hacker News API Stubs for testing
  """

  @behaviour HackerNews.API

  @impl true
  def top_stories(_config) do
    {:ok, [1234, 5678, 9012]}
  end

  @impl true
  def get_item(_config, id) do
    {:ok, %{"id" => id}}
  end
end
