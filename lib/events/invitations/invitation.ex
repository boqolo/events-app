defmodule Events.Invitations.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    field :response, :integer
   
    belongs_to :entry, Events.Entries.Entry
    belongs_to :user, Events.Users.User

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:entry_id, :user_id, :response])
    |> validate_required([:entry_id, :user_id, :response])
  end
end
