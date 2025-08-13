defmodule TWSAPIEx.Client.NetworkCodec do
  @moduledoc """
  This module handles the encoding and decoding of messages sent over the network.
  """

  require Logger

  require TWSAPIEx.Messages, as: Msg

  alias TWSAPIEx.Messages.Types.Integer, as: IntegerType
  alias TWSAPIEx.Messages.ServerMessages

  @behaviour ElvenGard.Network.NetworkCodec

  ## NetworkCodec behaviour

  # We use `packet: 4` opt so we should only get 1 packet at a time
  @impl true
  def next(data, _socket), do: {data, <<>>}

  @impl true
  def decode(raw, socket) do
    {packet_id, rest} = IntegerType.decode(raw)
    ServerMessages.deserialize(packet_id, rest, socket)
  rescue
    _e in FunctionClauseError ->
      {packet_id, rest} = IntegerType.decode(raw)
      fields = :binary.split(rest, <<0>>, [:global, :trim])
      Logger.warning("Failed to decode packet id:#{Msg.in(packet_id)} - #{inspect(fields)}")
      nil
  end

  @impl true
  def encode(struct, _socket) when is_struct(struct) do
    {message_id, params} = struct.__struct__.serialize(struct)

    message_id_field = message_id |> Integer.to_string() |> make_field()
    fields = Enum.map(params, &make_field/1)

    [message_id_field, fields]
  end

  ## Private functions

  def make_field(val) when is_binary(val), do: [val, <<0>>]
end
