defmodule HackerNews.APITest do
  use ExUnit.Case

  setup do
    hacker_news = HackerNews.API.new()

    {:ok, hacker_news: hacker_news}
  end

  describe "top_stories/1" do
    # TODO test error cases
    test "get top_stories limited by max_amount", %{hacker_news: hacker_news} do
      {:ok, response} = HackerNews.API.top_stories(hacker_news)

      assert length(response) == 3
    end
  end

  describe "get_item/2" do
    # TODO test error cases
    test "get_item retrieves item correctly", %{hacker_news: hacker_news} do
      item_id = 27_795_627
      {:ok, response} = HackerNews.API.get_item(hacker_news, item_id)

      assert response["id"] == item_id
    end
  end
end
