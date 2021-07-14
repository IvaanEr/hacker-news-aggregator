defmodule HackerNewsAggregatorWeb.ControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias HackerNewsAggregatorWeb.Controller
  alias HackerNewsAggregator.State

  setup do
    # Remember to take a look at HackerNews.Stub
    start_supervised!(State, start: {State, :start_link, [:state_test]})
    # Wait for the GenServer to initialize, avoid race condition
    :timer.sleep(200)

    :ok
  end

  describe "top stories" do
    setup do
      [conn: conn(:get, "/top_stories")]
    end

    test "get stories correctly", %{conn: conn} do
      assert %Plug.Conn{resp_body: body, status: 200} = Controller.get_stories(conn)

      assert %{"entries" => [%{"id" => 1234}, %{"id" => 5678}, %{"id" => 9012}]} =
               Jason.decode!(body)
    end

    test "get stories paginated", %{conn: conn} do
      conn = Map.put(conn, :params, %{"page_number" => "2", "page_size" => "5"})
      assert %Plug.Conn{resp_body: body, status: 200} = Controller.get_stories(conn)

      assert %{"page_number" => 2, "page_size" => 5} = Jason.decode!(body)
    end
  end

  describe "get story" do
    setup do
      [conn: conn(:get, "/story", %{id: 1234})]
    end

    test "get story correctly", %{conn: conn} do
      assert %Plug.Conn{resp_body: body, status: 200} = Controller.get_story(conn)

      assert %{"id" => "1234"} = Jason.decode!(body)
    end
  end
end
