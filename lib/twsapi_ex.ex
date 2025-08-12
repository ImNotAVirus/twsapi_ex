defmodule TWSAPIEx do
  @moduledoc """
  Documentation for `TWSAPIEx`.
  """

  @doc """
  This function must be called before any other. There is no
  feedback for a successful connection, but a subsequent attempt to
  connect will return the message \"Already connected.\"

  host:str - The host name or IP address of the machine where TWS is
      running. Leave blank to connect to the local host.
  port:int - Must match the port specified in TWS on the
      Configure>API>Socket Port field.
  client_id:int - A number used to identify this client connection. All
      orders placed/modified from this client will be associated with
      this client identifier.

      Note: Each client MUST connect with a unique client_id.
  """
  def connect(host, port, client_id \\ 0) do
    DynamicSupervisor.start_child(
      TWSAPIEx.DynamicSupervisor,
      {TWSAPIEx.Client, [host: host, port: port, client_id: client_id]}
    )
  end

  def test() do
    {:ok, pid} = connect("172.28.176.1", 7497)

    :ok = TWSAPIEx.Client.wait_for_connection(pid)

    # https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#requesting-account-summary
    TWSAPIEx.Client.req_account_summary(pid, "All", "NetLiquidation") |> IO.inspect()

    :ok
  end
end
