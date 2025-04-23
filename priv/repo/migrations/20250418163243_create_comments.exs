defmodule CommentsApp.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text
      add :author, :string

      timestamps()
    end
  end
end
