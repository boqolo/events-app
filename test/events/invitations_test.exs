defmodule Events.InvitationsTest do
  use Events.DataCase

  alias Events.Invitations

  describe "invitations" do
    alias Events.Invitations.Invitation

    @valid_attrs %{event_id: 42, response: 42, user_id: 42}
    @update_attrs %{event_id: 43, response: 43, user_id: 43}
    @invalid_attrs %{event_id: nil, response: nil, user_id: nil}

    def invitation_fixture(attrs \\ %{}) do
      {:ok, invitation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Invitations.create_invitation()

      invitation
    end

    test "list_invitations/0 returns all invitations" do
      invitation = invitation_fixture()
      assert Invitations.list_invitations() == [invitation]
    end

    test "get_invitation!/1 returns the invitation with given id" do
      invitation = invitation_fixture()
      assert Invitations.get_invitation!(invitation.id) == invitation
    end

    test "create_invitation/1 with valid data creates a invitation" do
      assert {:ok, %Invitation{} = invitation} = Invitations.create_invitation(@valid_attrs)
      assert invitation.event_id == 42
      assert invitation.response == 42
      assert invitation.user_id == 42
    end

    test "create_invitation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invitations.create_invitation(@invalid_attrs)
    end

    test "update_invitation/2 with valid data updates the invitation" do
      invitation = invitation_fixture()
      assert {:ok, %Invitation{} = invitation} = Invitations.update_invitation(invitation, @update_attrs)
      assert invitation.event_id == 43
      assert invitation.response == 43
      assert invitation.user_id == 43
    end

    test "update_invitation/2 with invalid data returns error changeset" do
      invitation = invitation_fixture()
      assert {:error, %Ecto.Changeset{}} = Invitations.update_invitation(invitation, @invalid_attrs)
      assert invitation == Invitations.get_invitation!(invitation.id)
    end

    test "delete_invitation/1 deletes the invitation" do
      invitation = invitation_fixture()
      assert {:ok, %Invitation{}} = Invitations.delete_invitation(invitation)
      assert_raise Ecto.NoResultsError, fn -> Invitations.get_invitation!(invitation.id) end
    end

    test "change_invitation/1 returns a invitation changeset" do
      invitation = invitation_fixture()
      assert %Ecto.Changeset{} = Invitations.change_invitation(invitation)
    end
  end
end
