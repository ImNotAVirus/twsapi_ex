defmodule TWSAPIEx.Messages.Types.Integer do
  @moduledoc """
  This module defines the integer type for the TWS API.
  """

  use ElvenGard.Network.Type

  alias TWSAPIEx.Messages.TypeHelpers

  @type t :: integer()

  ## Behaviour impls

  @impl true
  @spec decode(binary(), Keyword.t()) :: {t(), binary()}
  def decode(data, _opts) when is_binary(data) do
    {field, rest} = TypeHelpers.split_field(data)
    {String.to_integer(field), rest}
  end

  @impl true
  @spec encode(t(), Keyword.t()) :: iodata()
  def encode(data, _opts) when is_integer(data) do
    data
    |> Integer.to_string()
    |> TypeHelpers.encode_field()
  end
end
