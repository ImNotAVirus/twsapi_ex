defmodule TWSAPIEx.Messages.Types.Float do
  @moduledoc """
  This module defines the float type for the TWS API.
  """

  use ElvenGard.Network.Type

  alias TWSAPIEx.Messages.TypeHelpers

  @type t :: float()

  ## Behaviour impls

  @impl true
  @spec decode(binary(), Keyword.t()) :: {t(), binary()}
  def decode(data, _opts) when is_binary(data) do
    {field, rest} = TypeHelpers.split_field(data)
    {String.to_float(field), rest}
  end

  @impl true
  @spec encode(t(), Keyword.t()) :: iodata()
  def encode(data, _opts) when is_float(data) do
    data
    |> Float.to_string()
    |> TypeHelpers.encode_field()
  end
end
