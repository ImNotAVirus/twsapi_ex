defmodule TWSAPIEx.Messages.ServerMessages do
  @moduledoc """
  This module defines the server messages used in the TWS API.
  """

  use ElvenGard.Network.PacketSerializer

  require TWSAPIEx.Messages, as: Msg

  alias TWSAPIEx.Messages.Types.{Float, Integer, String}

  ## Messages

  @deserializable true
  defpacket Msg.in(:account_summary), as: AccountSummary do
    field :version, Integer
    field :req_id, Integer
    field :account, String
    field :tag, String
    field :value, Float
    field :currency, String
  end

  @deserializable true
  defpacket Msg.in(:account_summary_end), as: AccountSummaryEnd do
    field :version, Integer
    field :req_id, Integer
  end
end
