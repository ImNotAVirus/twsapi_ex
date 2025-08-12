defmodule TWSAPIEx.Client.Handlers do
  @moduledoc false

  require Logger

  alias TWSAPIEx.Client

  ## Handlers

  def handle_message(
        :account_summary,
        [_version = "1", req_id, account, tag, value, currency],
        %Client{} = state
      ) do
    %Client{internal: internal} = state
    req_id = String.to_integer(req_id)

    payload = %{
      account: account,
      tag: tag,
      value: String.to_float(value),
      currency: currency
    }

    if Map.has_key?(internal, req_id) do
      Logger.warning("Overwriting account summary for req_id: #{req_id} - payload: #{payload}")
    end

    updated_internal = Map.put(internal, req_id, payload)
    updated_state = %Client{state | internal: updated_internal}

    {:ok, updated_state}
  end

  def handle_message(:account_summary_end, [_version = "1", req_id], %Client{} = state) do
    %Client{reply_map: reply_map, internal: internal} = state
    req_id = String.to_integer(req_id)

    {reply_from, updated_reply_map} = Map.pop!(reply_map, req_id)
    {payload, updated_internal} = Map.pop!(internal, req_id)

    :ok = GenServer.reply(reply_from, {:ok, payload})

    {:ok, %Client{state | reply_map: updated_reply_map, internal: updated_internal}}
  end

  def handle_message(type, args, state) do
    Logger.warning("Unhandled message of type #{inspect(type)} with args: #{inspect(args)}")
    {:ok, state}
  end
end
