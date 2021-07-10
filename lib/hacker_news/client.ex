defmodule HackerNews.Client do
  @moduledoc """
  Hacker News API Client implementation.
  """
  @behaviour HackerNews.API

  @impl true
  def top_stories(config) do
    url = "#{config.base_url}/topstories.json?print=pretty"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} ->
        {:ok,
         response
         |> Jason.decode!()
         |> Enum.take(config.max_amount)}

      error ->
        handle_error(error)
    end
  end

  @impl true
  def get_item(config, id) do
    url = "#{config.base_url}/item/#{id}.json?print=pretty"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} ->
        {:ok, Jason.decode!(response)}

      error ->
        handle_error(error)
    end
  end

  defp handle_error(error) do
    case error do
      {:ok, %HTTPoison.Response{status_code: status_code, body: response}} ->
        {:error, :top_stories, status_code, response}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, :top_stories, reason}
    end
  end
end
