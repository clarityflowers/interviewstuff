defmodule ApiTest.Main do
  require Logger

  defp per_group(group) do
    IO.puts("")
    IO.puts(List.first(group)["rel"]["label"])
    IO.puts("-----------------")
    group |> Enum.each(fn edge -> IO.puts(edge["start"]["label"] <> " -> " <> edge["end"]["label"]) end)
  end

  def main([arg | _rest]) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)
    ApiTest.Api.get_node(arg)
    |> Stream.filter(fn edge -> edge["start"]["language"] == "en" and edge["end"]["language"] == "en" end)
    |> Enum.sort(fn (a, b) -> a["rel"]["label"] > b["rel"]["label"] end)
    |> Stream.chunk_by(fn edge -> edge["rel"]["label"] end)
    |> Stream.each(&per_group/1)
    |> Stream.run
  end
end
