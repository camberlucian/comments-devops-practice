defmodule CommentsApp.Repo do
  use Ecto.Repo,
    otp_app: :comments_app,
    adapter: Ecto.Adapters.Postgres
end
