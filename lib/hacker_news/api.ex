defmodule HackerNews.API do
  @moduledoc """
  Hacker News API
  https://github.com/HackerNews/API
  """

  @type t :: %__MODULE__{}
  @type id :: non_neg_integer()
  @type item :: map()

  @callback top_stories(config :: __MODULE__.t()) :: [id()]
  @callback get_item(config :: __MODULE__.t(), id()) :: map()

  defstruct(
    client_module: nil,
    base_url: nil,
    max_amount: nil
  )

  @spec new() :: %__MODULE__{}
  def new do
    env = get_env()
    client_module = Keyword.get(env, :client_module, HackerNews.Client)
    base_url = Keyword.fetch!(env, :base_url)
    max_amount = Keyword.get(env, :max_amount, 50)

    %__MODULE__{
      client_module: client_module,
      base_url: base_url,
      max_amount: max_amount
    }
  end

  def top_stories(config) do
    config.client_module.top_stories(config)
  end

  def get_item(config, id) do
    config.client_module.get_item(config, id)
  end

  defp get_env, do: Application.get_env(:hacker_news_aggregator, __MODULE__)
end
