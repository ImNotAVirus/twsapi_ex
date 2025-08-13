defmodule TWSAPIEx.Messages.Types.String do
  @moduledoc """
  This module defines the string type for the TWS API.
  """

  use ElvenGard.Network.Type

  alias TWSAPIEx.Messages.TypeHelpers

  @type t :: String.t()

  ## Behaviour impls

  @impl true
  @spec decode(binary(), Keyword.t()) :: {t(), binary()}
  def decode(data, _opts) when is_binary(data) do
    TypeHelpers.split_field(data)
  end

  @impl true
  @spec encode(t(), Keyword.t()) :: iodata()
  def encode(data, _opts) when is_binary(data) do
    data
  end
end
