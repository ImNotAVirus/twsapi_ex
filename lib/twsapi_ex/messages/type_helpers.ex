defmodule TWSAPIEx.Messages.TypeHelpers do
  @moduledoc """
  This module defines helpers for the TWS API message types.
  """

  ## Public API

  @spec split_field(binary()) :: {binary(), binary()}
  def split_field(binary) when is_binary(binary) do
    case :binary.split(binary, <<0>>) do
      [field] -> {field, <<>>}
      [field, rest] -> {field, rest}
    end
  end

  @spec encode_field(binary()) :: iodata()
  def encode_field(val) when is_binary(val) do
    [val, <<0>>]
  end
end
