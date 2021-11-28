defmodule DemoHttpStreamWeb.DemoController do
  use DemoHttpStreamWeb, :controller

  @doc """
  用 stream 的形式返回一批数据

  数据中每行是一个 JSON 字符串加上换行符。

  ## Params

    * `rows` - 响应数据的行数。默认值 10
    * `keys` - 每行数据中除了 `id` 以外的键数量，对应值是 UUID 。默认值 10

  """
  def stream(conn, params) do
    params = stream_params(params)
    conn = send_chunked(conn, 200)

    1..params.rows
    |> Enum.reduce(conn, fn row_idx, conn ->
      # 每次休息一段时间再发送
      Process.sleep(200)

      row =
        random_json(params.keys)
        |> Map.put("id", row_idx)
        |> Jason.encode!()
        |> Kernel.<>("\n")

      case chunk(conn, row) do
        {:ok, conn} -> conn
      end
    end)
  end

  defp random_json(keys) do
    1..keys
    |> Map.new(fn i ->
      {"key#{i}", Ecto.UUID.generate()}
    end)
  end

  defp stream_params(params) do
    types = %{
      rows: :integer,
      keys: :integer
    }

    params =
      {%{}, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
      |> Ecto.Changeset.apply_changes()

    Map.merge(%{rows: 10, keys: 10}, params)
  end
end
