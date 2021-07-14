import Config

config :hacker_news_aggregator, HackerNews.API,
  client_module: HackerNews.Client,
  base_url: "https://hacker-news.firebaseio.com/v0/",
  max_amount: 50

config :hacker_news_aggregator, HackerNewsAggregatorWeb.SocketHandler,
  registry_key: :hacker_news_ws

import_config "#{Mix.env()}.exs"
