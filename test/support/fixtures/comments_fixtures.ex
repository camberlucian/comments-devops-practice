defmodule CommentsApp.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CommentsApp.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        author: "some author",
        body: "some body"
      })
      |> CommentsApp.Comments.create_comment()

    comment
  end
end
