defmodule EventsWeb.CommentController do
  use EventsWeb, :controller

  require Logger

  alias Events.Comments
  alias Events.Comments.Comment
  alias Events.Entries

  def new(conn, %{"entry_id" => id} = _params) do
    entry = Entries.get_and_load_entry!(id)
    changeset = Comments.change_comment(%Comment{})
    render(conn, "new.html", entry: entry, changeset: changeset)
  end

  def create(conn, %{"comment" => body, "entry_id" => entry_id}) do
    preparedParams = 
      body
      |> Map.put("entry_id", entry_id)
      |> Map.put("user_id", conn.assigns[:currentUser].id)
    case Comments.create_comment(preparedParams) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment posted successfully")
        |> redirect(to: Routes.entry_path(conn, :show, entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Oops. Your comment couldn't be added")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    changeset = Comments.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully")
        # |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully")
    # |> redirect(to: Routes.comment_path(conn, :index))
  end
end
