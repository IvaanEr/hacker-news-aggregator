use Mix.Config

# config :logger, level: :info

config :hacker_news_aggregator, HackerNews.API,
  client_module: HackerNews.Stub,
  base_url: "http://localhost:50123/v0",
  max_amount: 10

config :hacker_news_aggregator, :env, :test
