defmodule Cog.Command.Request do

  use Cog.Marshalled
  require Logger

  defmarshalled [:room, :requestor, :user, :command, :args, :options,
                 :command_config, :reply_to, :cog_env, :invocation_id,
                 :invocation_step, :service_token, :services_root]

  defp validate(request) do
    cond do
      request.room == nil ->
        {:error, {:empty_field, :room}}
      request.requestor == nil ->
        {:error, {:empty_field, :requestor}}
      request.command == nil ->
        {:error, {:empty_field, :command}}
      request.reply_to == nil ->
        {:error, {:empty_field, :reply_to}}
      true -> {:ok, request}
    end
  end
end
