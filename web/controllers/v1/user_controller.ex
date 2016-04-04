defmodule Cog.V1.UserController do
  import Plug.Conn

  use Cog.Web, :controller

  alias Cog.Models.User

  plug Cog.Plug.Authentication
  plug :check_self_updating, [permission: "#{Cog.embedded_bundle}:manage_users"]

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    |> Repo.preload(:direct_group_memberships)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Cog.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    |> Repo.preload(:direct_group_memberships)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        updated = Repo.preload(user, :direct_group_memberships)
        render(conn, "show.json", user: updated)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Cog.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    Repo.delete!(user)
    send_resp(conn, :no_content, "")
  end

  ###############################################
  # Plug function - local only to user controller
  ###############################################
  @spec check_self_updating(Plug.Conn.t, []) :: Plug.Conn.t
  def check_self_updating(conn, opts \\ []) do
    if determine_self_updating(conn) do
      conn
    else
      plug_opts = Cog.Plug.Authorization.init(opts)
      Cog.Plug.Authorization.call(conn, plug_opts)
    end
  end

    @doc """
  Store the self updating user flag in the `conn`.
  """
  @spec determine_self_updating(%Plug.Conn{}) :: true | false
  def determine_self_updating(conn) do
    Map.has_key?(conn.private, :phoenix_action) and
        conn.private.phoenix_action == :update and
        conn.assigns.user.id == conn.params["id"]
  end

end

