defmodule DemoHttpStream.Receiver1 do
  @moduledoc """
  HTTP 流的接收方。用 HTTPoison 实现
  """

  def run do
    resp =
      HTTPoison.get!(
        "http://localhost:4000/api/stream?rows=10",
        %{},
        stream_to: self(),
        async: :once
      )

    receive_and_stream_next(resp)
  end

  defp receive_and_stream_next(resp) do
    resp_id = resp.id

    receive do
      %HTTPoison.AsyncStatus{code: code, id: ^resp_id} ->
        IO.inspect("Status code: #{code}")
        {:ok, resp} = HTTPoison.stream_next(resp)
        receive_and_stream_next(resp)

      %HTTPoison.AsyncHeaders{headers: headers, id: ^resp_id} ->
        IO.puts("Headers:")
        IO.inspect(headers)
        {:ok, resp} = HTTPoison.stream_next(resp)
        receive_and_stream_next(resp)

      %HTTPoison.AsyncChunk{chunk: chunk, id: ^resp_id} ->
        IO.puts("Chunk:")

        case Jason.decode(chunk) do
          {:ok, decoded_chunk} ->
            IO.inspect(decoded_chunk)

          _ ->
            IO.puts("Invalid JSON")
            IO.inspect(chunk)
        end

        {:ok, resp} = HTTPoison.stream_next(resp)
        receive_and_stream_next(resp)

      %HTTPoison.AsyncEnd{id: ^resp_id} ->
        IO.puts("Finished")
    end
  end
end
