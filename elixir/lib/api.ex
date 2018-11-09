defmodule ApiTest.Api do

  require Logger

  defp fetch path do
    url = 'http://api.conceptnet.io' ++ String.to_charlist(path)
    case :httpc.request(url) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} -> {:ok, Poison.decode!(body)} 
      otherwise -> {:error, otherwise}
    end
  end

  defp stream_value({[], nil}) do
    nil
  end

  defp stream_value({[], next_page}) do
    case fetch(next_page) do
      {:ok, %{"edges" => [first | rest], "view" => %{"nextPage" => next_page}}} -> {first, {rest, next_page}}
      {:ok, %{"edges" => [first | rest]}} -> {first, {rest, nil}}
      {:error, _anything} -> nil
    end
  end

  defp stream_value({[edge | rest], next_page}) do
    {edge, {rest, next_page}}
  end

  defp get path do
    Stream.unfold({[], path}, &stream_value/1)
  end

  def get_node node do
    get("/c/en/" <> node <> "?limit=100")
  end
end
