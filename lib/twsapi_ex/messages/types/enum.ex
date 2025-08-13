defmodule TWSAPIEx.Messages.Types.Enum do
  @moduledoc """
  This module defines the enum type for the TWS API.
  """

  use ElvenGard.Network.Type

  alias TWSAPIEx.Messages.Types.Integer

  @type t :: atom()

  ## Behaviour impls

  @impl true
  @spec decode(binary(), Keyword.t()) :: {t(), binary()}
  def decode(data, opts) when is_binary(data) do
    # Enum, values: [status: 1, login: 2]
    {enumerators, opts} = Keyword.pop!(opts, :values)

    {id, rest} = Integer.decode(data, opts)
    {key, _v} = Enum.find(enumerators, &(elem(&1, 1) == id))

    {key, rest}
  end

  @impl true
  @spec encode(t(), Keyword.t()) :: iodata()
  def encode(data, opts) when is_atom(data) do
    # Enum, values: [status: 1, login: 2]
    {enumerators, opts} = Keyword.pop!(opts, :values)

    enumerators
    |> Keyword.fetch!(data)
    |> Integer.encode(opts)
  end
end
