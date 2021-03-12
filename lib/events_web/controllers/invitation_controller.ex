defmodule EventsWeb.InvitationController do
  use EventsWeb, :controller

  # Gotta love plugs ;)
  plug EventsWeb.Plugs.UserInvite when action not in [:show, :update]
  plug EventsWeb.Plugs.RequireUser
  # FIXME plug EventsWeb.Plugs.EntryExists

  require Logger

  alias Events.Invitations
  alias Events.Invitations.Invitation
  alias Events.Entries
  alias Events.Users

  def index(conn, %{"entry_id" => entry_id}) do
    entry = Entries.get_and_load_entry!(entry_id)
    inviteStats = Entries.getEntryInvitationStats(entry)
    invitations = Invitations.list_invitations()
    render(conn, "index.html", invitations: invitations, entry: entry, stats: inviteStats)
  end

  def new(conn, %{"entry_id" => entry_id}) do
    entry = Entries.get_and_load_entry!(entry_id)
    changeset = Invitations.change_invitation(%Invitation{})
    render(conn, "new.html", changeset: changeset, entry: entry)
  end

  def validEmail?(str) do
    # rough email validation
    String.match?(str, ~r/((^[@]|[\.]|\w)+)@(.+)/)
  end

  def parseEmails(str) do
    potentialEmails = 
      str
      |> String.split(~r/,/, trim: true)
      |> Enum.map(fn(s) -> String.trim(s) end)
      |> Enum.uniq()
    validEmails = Enum.filter(potentialEmails, fn(e) -> validEmail?(e) end)
    invalidEmails = Enum.reject(potentialEmails, fn(e) -> validEmail?(e) end)
    {validEmails, invalidEmails}
  end

  def createInvitations(entry_id, validEmails) do
    Enum.reduce(
      validEmails, 
      [], 
      fn(email, acc) -> 
        user? = Users.getUserByEmail(email)
        userAttrs = if user? do
          %{"user_id" => user?.id} 
        else
          # create user if non-existent
          case Users.create_user(%{"email" => email, "name" => "---"}) do
            # use placeholder name
            {:ok, user} -> %{"user_id" => user.id} 
            {:error, changeset} -> 
              Logger.debug("USER CHSET ---> #{inspect(changeset)}")
              %{"user_id" => -1}
              # fatal error. will cause email to be caught 
              # as 'bad invite' in creation step because of 
              # an added foreign_key_constraint on invitations
          end
        end
        Logger.debug("USER ATTRS ---> #{inspect(userAttrs)}")
        attrs = Map.merge(%{"entry_id" => entry_id, "email" => email}, userAttrs)
        Logger.debug("ATTRS ---> #{inspect(attrs)}")
        case Invitations.create_invitation(attrs) do
          {:ok, invitation} -> 
            Logger.debug("CREATED INVITE ---> #{inspect(invitation)}")
            acc
          {:error, %Ecto.Changeset{} = _changeset} -> 
            Logger.debug("BAD INVITE ---> #{email}")
            [email | acc]
        end
      end
    )
  end

  defp successfulInvitations(validEmails, validEmailErrors) do
    validSet = MapSet.new(validEmails)
    invalidSet = MapSet.new(validEmailErrors)
    MapSet.difference(validSet, invalidSet)
    |> MapSet.to_list()
  end


  def create(conn, %{"invitation" => invite_params, "entry_id" => entry_id} = params) do
    Logger.debug("InvitationController ---> #{inspect(params)}")
    {validEmails, invalidEmails} = parseEmails(invite_params["emails"])
    Logger.debug("VALID EMAILS ---> #{inspect(validEmails)}")
    Logger.debug("INVALID EMAILS ---> #{inspect(invalidEmails)}")
    validEmailErrors = createInvitations(String.to_integer(entry_id), validEmails)
    Logger.debug("FAILED EMAILS ---> #{inspect(validEmailErrors)}")
    successes = successfulInvitations(validEmails, validEmailErrors)
    [numSuccess, numInvalid, numFailed] = [
      Enum.count(successes),
      Enum.count(invalidEmails),
      Enum.count(validEmailErrors)
    ]
    if numSuccess > 0 do
      conn
      |> put_flash(
        :success, 
        "#{numSuccess} invitation(s) created."
      )
      |> (fn(conn) -> 
        if numFailed > 0, 
          do: put_flash(
            conn,
            :info,
            "#{numFailed} invitation(s) couldn't be created"
          ),
          else: conn
        end).()
      |> (fn(conn) -> 
        if numInvalid > 0, 
          do: put_flash(
            conn, 
            :error, 
            "#{numInvalid} invalid emails: #{Enum.join(invalidEmails, ", ")}"
          ), 
          else: conn
        end).()
      |> redirect(to: Routes.entry_invitation_path(conn, :index, entry_id))
    else
      conn
      |> (fn(conn) -> 
        if numFailed > 0, 
          do: put_flash(
            conn, 
            :info, 
            "#{numFailed} invitation(s) couldn't be created"
          ),
          else: conn
        end).()
      |> (fn(conn) -> 
        if numInvalid > 0, 
          do: put_flash(
            conn, 
            :error, 
            "#{numInvalid} invalid emails: #{Enum.join(invalidEmails, ", ")}"
          ),
          else: conn
        end).()
      |> redirect(to: Routes.entry_invitation_path(conn, :new, entry_id))
    end
  end

  def show(conn, %{"entry_id" => entry_id, "id" => id}) do
    Logger.debug("INVIT CONTOLLER SHOW ---> entry: #{entry_id} invit_id: #{id}")
    entry = Entries.get_and_load_entry!(entry_id)
    invitation = Invitations.get_invitation!(id)
    changeset = Invitations.change_invitation(invitation)
    render(conn, "show.html", entry: entry, invitation: invitation, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    invitation = Invitations.get_invitation!(id)
    changeset = Invitations.change_invitation(invitation)
    render(conn, "edit.html", invitation: invitation, changeset: changeset)
  end

  def update(conn, %{"entry_id" => entry_id, "id" => invit_id} = params) do
    %{"invitation" => %{"response" => resp}} = params
    Logger.debug("INVIT CONTOLLER UPDATE ---> #{inspect(params)}")
    unless Enum.member?(["1", "-1", "0"], resp) do
      conn
      |> put_flash(:error, "That response couldn't be recognized")
    else
      invitation = Invitations.get_invitation!(invit_id)
      attrs = %{"response" => String.to_integer(resp)}

      case Invitations.update_invitation(invitation, attrs) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Your response has been recorded")
          |> redirect(to: Routes.entry_path(conn, :show, entry_id))
        {:error, %Ecto.Changeset{} = _changeset} ->
          conn
          |> put_flash(:error, "Your response couldn't be recorded")
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    invitation = Invitations.get_invitation!(id)
    {:ok, _invitation} = Invitations.delete_invitation(invitation)

    conn
    |> put_flash(:info, "Invitation deleted successfully")
    |> redirect(to: Routes.invitation_path(conn, :index))
  end
end
