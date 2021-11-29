defmodule DemoHttpStream.Receiver2 do
  @moduledoc """
  HTTP 流的接收方。用 Mint 实现
  """

  def run do
    {:ok, conn} = Mint.HTTP.connect(:http, "localhost", 4000)
    {:ok, conn, req_ref} = Mint.HTTP.request(conn, "GET", "/api/stream", [], "")
    receive_and_stream_next(conn, req_ref)
  end

  defp receive_and_stream_next(conn, req_ref) do
    IO.puts("Receive conn:")

    receive do
      message ->
        case handle_message(message, conn, req_ref) do
          {:ok, conn, :processing} ->
            receive_and_stream_next(conn, req_ref)

          {:ok, conn, :done} ->
            if Mint.HTTP.open?(conn) do
              IO.puts("Closing conn if open")
              Mint.HTTP.close(conn)
              IO.puts("Closed")
            end

            nil

          {:error, _conn} ->
            nil
        end
    after
      1_000 ->
        IO.inspect("Timeout, finished")
    end
  end

  defp handle_message(message, conn, req_ref) do
    case Mint.HTTP.stream(conn, message) do
      {:ok, conn, resps} ->
        result =
          Enum.reduce(resps, :processing, fn resp, result ->
            case resp do
              {:status, ^req_ref, code} ->
                IO.inspect("Status code: #{code}")
                result

              {:headers, ^req_ref, headers} ->
                IO.puts("Headers:")
                IO.inspect(headers)
                result

              {:data, ^req_ref, chunk} ->
                IO.puts("Chunk:")

                case Jason.decode(chunk) do
                  {:ok, decoded_chunk} ->
                    IO.inspect(decoded_chunk)

                  _ ->
                    IO.puts("Invalid JSON")
                    IO.inspect(chunk)
                end

                result

              {:done, ^req_ref} ->
                IO.puts("Done")
                :done
            end
          end)

        {:ok, conn, result}

      {:error, conn, error, resps} ->
        IO.inspect("Error:")
        IO.inspect(conn)
        IO.inspect(error)
        IO.inspect(resps)
        {:error, conn}
    end
  end
end
