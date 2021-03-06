defmodule Events.Entries.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :description, :string, null: false
    field :date, :utc_datetime, null: false
    field :name, :string, null: false

    field :resp_accept, :integer, virtual: true
    field :resp_decline, :integer, virtual: true
    field :resp_none, :integer, virtual: true

    belongs_to :user, Events.Users.User
    has_many :invitations, Events.Invitations.Invitation 

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:name, :date, :description, :user_id])
    |> validate_required([:name, :date, :description, :user_id])
  end
end
