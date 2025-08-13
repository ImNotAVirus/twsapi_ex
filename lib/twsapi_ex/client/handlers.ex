defmodule TWSAPIEx.Client.Handlers do
  @moduledoc false

  require Logger

  alias TWSAPIEx.Client

  alias TWSAPIEx.Messages.ServerMessages.{
    AccountSummary,
    AccountSummaryEnd
  }

  ## Handlers

  def handle_message(%AccountSummary{} = struct, %Client{} = state) do
    %AccountSummary{req_id: req_id, account: account, tag: tag, value: value, currency: currency} =
      struct

    %Client{internal: internal} = state

    payload = %{account: account, tag: tag, value: value, currency: currency}

    if Map.has_key?(internal, req_id) and internal[req_id] != payload do
      old = internal[req_id]

      Logger.warning(
        "Overwriting account summary for req_id: #{req_id} " <>
          "- old: #{inspect(old)} - new: #{inspect(payload)}"
      )
    end

    updated_internal = Map.put(internal, req_id, payload)
    updated_state = %Client{state | internal: updated_internal}

    {:ok, updated_state}
  end

  def handle_message(%AccountSummaryEnd{} = struct, %Client{} = state) do
    %AccountSummaryEnd{req_id: req_id} = struct
    %Client{reply_map: reply_map, internal: internal} = state

    {reply_from, updated_reply_map} = Map.pop!(reply_map, req_id)
    {payload, updated_internal} = Map.pop!(internal, req_id)

    :ok = GenServer.reply(reply_from, {:ok, payload})

    {:ok, %Client{state | reply_map: updated_reply_map, internal: updated_internal}}
  end
end
