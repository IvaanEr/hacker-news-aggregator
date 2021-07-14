defmodule HackerNewsAggregatorWeb.Router do
  use Plug.Router

  alias HackerNewsAggregatorWeb.Controller

  plug(:fetch_query_params)
  plug(:match)
  plug(:dispatch)

  get "/top_stories" do
    Controller.get_stories(conn)
  end

  get "/story" do
    Controller.get_story(conn)
  end

  match _ do
    send_resp(conn, 404, "Page Not Found")
  end
end
