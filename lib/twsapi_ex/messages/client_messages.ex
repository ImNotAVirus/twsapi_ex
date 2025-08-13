defmodule TWSAPIEx.Messages.ClientMessages do
  @moduledoc """
  This module defines the client messages for the TWS API.
  """

  use ElvenGard.Network.PacketSerializer

  require TWSAPIEx.Messages, as: Msg

  import TWSAPIEx.ServerVersions, only: [min_server_ver: 1]

  alias TWSAPIEx.Messages.Types.{Enum, Integer, String}

  ## Helpers

  defmacro min_version(socket, version) do
    quote location: :keep do
      unquote(socket).server_version >= unquote(min_server_ver(version))
    end
  end

  ## Handshake packets

  @serializable true
  defpacket Msg.out(:start_api), as: StartAPI do
    field :version, Integer, default: 2
    field :client_id, Integer
    field :opt_capabilities, String, default: "", if: min_version(socket, :optional_capabilities)
  end

  ## Reqs

  @serializable true
  defpacket Msg.out(:req_account_summary), as: ReqAccountSummary do
    field :version, Integer, default: 1
    field :req_id, Integer
    field :group, String
    field :tags, String
  end

  @serializable true
  defpacket Msg.out(:req_market_data_type), as: ReqMarketDataType do
    field :version, Integer, default: 1
    field :market_data_type, Enum, values: [live: 1, frozen: 2, delayed: 3, delayed_frozen: 4]
  end
end
