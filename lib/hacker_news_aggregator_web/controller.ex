defmodule HackerNewsAggregatorWeb.Controller do
  import Plug.Conn

  alias HackerNewsAggregator.State

  def get_stories(conn) do
    config = build_pagination_config(conn.query_params)

    page =
      State.get_top_stories()
      |> Scrivener.paginate(config)
      |> Map.from_struct()
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, page)
  end

  def get_story(conn) do
    case Map.get(conn.query_params, "id", nil) do
      nil ->
        conn
        |> send_resp(400, "provide story id as query param")

      id ->
        story =
          id
          |> State.get_top_story()
          |> Jason.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, story)
    end
  end

  defp build_pagination_config(%{"page" => page_number, "page_size" => page_size}),
    do: %Scrivener.Config{
      page_number: String.to_integer(page_number),
      page_size: String.to_integer(page_size)
    }

  defp build_pagination_config(%{"page" => page_number}),
    do: %Scrivener.Config{page_number: page_number, page_size: 10}

  defp build_pagination_config(_params), do: %Scrivener.Config{page_number: 1, page_size: 10}
end
