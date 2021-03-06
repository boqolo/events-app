defmodule Events.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string

    belongs_to :user, Events.Users.User
    belongs_to :entry, Events.Entries.Entry

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :entry_id, :user_id])
    |> validate_required([:body, :entry_id, :user_id])
  end
end
