defmodule DemoHttpStream.Repo do
  use Ecto.Repo,
    otp_app: :demo_http_stream,
    adapter: Ecto.Adapters.Postgres
end
