defmodule TWSAPIEx.Messages.Types.Boolean do
  @moduledoc """
  This module defines the boolean type for the TWS API.
  """

  use ElvenGard.Network.Type

  alias TWSAPIEx.Messages.TypeHelpers

  @type t :: boolean()

  ## Behaviour impls

  @impl true
  @spec decode(binary(), Keyword.t()) :: {t(), binary()}
  def decode(data, _opts) when is_binary(data) do
    {field, rest} = TypeHelpers.split_field(data)

    value =
      case field do
        "1" -> true
        "0" -> false
      end

    {value, rest}
  end

  @impl true
  @spec encode(t(), Keyword.t()) :: iodata()
  def encode(data, _opts) when is_boolean(data) do
    TypeHelpers.encode_field(if data, do: "1", else: "0")
  end
end
