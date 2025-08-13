defmodule TWSAPIEx.Messages.ClientMessages do
  @moduledoc """
  This module defines the client messages for the TWS API.
  """

  use ElvenGard.Network.PacketSerializer

  require TWSAPIEx.Messages, as: Msg

  alias TWSAPIEx.Messages.Types.{Integer, String}

  ## Handshake packets

  @serializable true
  defpacket Msg.out(:start_api), as: StartAPIOld do
    field :version, Integer, default: 2
    field :client_id, Integer
  end

  @serializable true
  defpacket Msg.out(:start_api), as: StartAPI do
    field :version, Integer, default: 2
    field :client_id, Integer
    field :opt_capabilities, String, default: ""
  end

  ## Reqs

  @serializable true
  defpacket Msg.out(:req_account_summary), as: ReqAccountSummary do
    field :version, Integer, default: 1
    field :req_id, Integer
    field :group, String
    field :tags, String
  end
end
