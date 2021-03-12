defmodule Events.Invitations.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    field :response, :integer # 1 = accepted, -1 = declined, 0 = no response
    field :email, :string
   
    belongs_to :entry, Events.Entries.Entry
    belongs_to :user, Events.Users.User

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:entry_id, :user_id, :response, :email])
    |> validate_required([:entry_id, :email])
    |> foreign_key_constraint(:user_id)
  end
end
