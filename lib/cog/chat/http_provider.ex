defmodule Cog.Chat.HttpProvider do

  require Logger

  use GenServer
  use Cog.Chat.Provider

  def start_link(_config),
    do: GenServer.start_link(__MODULE__, [])

  def send_message(room, response),
    do: Cog.Adapters.Http.AdapterBridge.finish_request(room, response)

  def lookup_room(_room),
    do: {:error, :not_found}

  # TODO: Do we need this implementation?
  def mention_name(name),
    do: name

  def display_name,
    do: "HTTP"

end
