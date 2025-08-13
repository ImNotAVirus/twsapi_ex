defmodule TWSAPIEx.Comm do
  @moduledoc """
  This module has tools for implementing the IB low level messaging.
  """

  @doc """
  Adds the length prefix
  """
  @spec make_msg(iodata()) :: iodata()
  def make_msg(data) do
    [<<:erlang.iolist_size(data)::32>>, data]
  end

  @doc """
  First the size prefix and then the corresponding msg payload
  """
  @spec read_msg(binary()) :: {non_neg_integer(), String.t(), binary()}
  def read_msg(buf) do
    case buf do
      <<size::32, text::binary-size(size), rest::binary>> -> {size, text, rest}
      _ -> {0, "", buf}
    end
  end

  @doc """
  msg payload is made of fields terminated/separated by NULL chars
  """
  @spec read_fields(binary()) :: [binary()]
  def read_fields(buf) do
    :binary.split(buf, <<0>>, [:global, :trim])
  end
end
