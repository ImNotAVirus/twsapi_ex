defmodule TWSAPIEx.Client do
  @moduledoc """
  The main class to use from API user's point of view.

  It takes care of almost everything:
  - implementing the requests
  - creating the answer decoder
  - creating the connection to TWS/IBGW
  The user just needs to override EWrapper methods to receive the answers.
  """

  use GenServer

  require Logger
  require TWSAPIEx.Messages, as: Msg
  require TWSAPIEx.ServerVersions, as: ServerVersions

  alias __MODULE__
  alias __MODULE__.Handlers
  alias TWSAPIEx.Client.NetworkCodec
  alias TWSAPIEx.Comm
  alias TWSAPIEx.MessageViews

  defstruct [
    :host,
    :port,
    :client_id,
    :socket,
    :conn_time,
    :server_version,
    reply_map: %{},
    internal: %{},
    opt_capabilities: ""
  ]

  ## Public API

  @doc false
  def start_link(opts) do
    genserver_opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, genserver_opts)
  end

  @doc """
  Waits for the client to establish a connection.
  """
  @spec wait_for_connection(pid(), timeout()) :: :ok
  def wait_for_connection(pid, timeout \\ :infinity) do
    GenServer.call(pid, :wait_for_connection, timeout)
  end

  @doc """
  Requests a specific account’s summary.

  This method will subscribe to the account summary as presented in the TWS’ Account
  Summary tab. Customers can specify the data received by using a specific tags value.  
  See the Account Summary Tags section for available options.

  Alternatively, many languages offer the import of AccountSummaryTags with a method to retrieve all tag values.

  cf. https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#requesting-account-summary
  """
  @spec req_account_summary(pid(), String.t(), String.t()) :: {:ok, map()}
  def req_account_summary(client, group, tags) do
    GenServer.call(client, {:req_account_summary, group, tags})
  end

  @doc """
  Switches data type returned from reqMktData request to Live (1), Frozen (2), Delayed (3), or Frozen-Delayed (4).

  cf. https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#request-md-type
  """
  @spec req_market_data_type(pid(), atom()) :: :ok
  def req_market_data_type(client, market_data_type) do
    GenServer.call(client, {:req_market_data_type, market_data_type})
  end

  @doc """
  all this function to request market data.

  The market data will be returned by the tickPrice and tickSize events.

  contract:Contract - This structure contains a description of the
      Contract for which market data is being requested.
  genericTickList:str - A commma delimited list of generic tick types.
      Tick types can be found in the Generic Tick Types page.
      Prefixing w/ 'mdoff' indicates that top mkt data shouldn't tick.
      You can specify the news source by postfixing w/ ':<source>.
      Example: "mdoff,292:FLY+BRF"
  snapshot:bool - Check to return a single snapshot of Market data and
      have the market data subscription cancel. Do not enter any
      genericTicklist values if you use snapshots.
  regulatorySnapshot: bool - With the US Value Snapshot Bundle for stocks,
      regulatory snapshots are available for 0.01 USD each.
  mktDataOptions:TagValueList - For internal use only.
      Use default value XYZ.
  """
  def req_mkt_data(
        client,
        contract,
        generic_tick_list,
        snapshot \\ false,
        regulatory_snapshot \\ false,
        data_options \\ []
      ) do
    GenServer.call(
      client,
      {:req_mkt_data, contract, generic_tick_list, snapshot, regulatory_snapshot, data_options}
    )
  end

  ## GenServer behaviour

  @impl true
  def init(opts) do
    state = %Client{
      host: mandatory_opt!(opts, :host),
      port: mandatory_opt!(opts, :port),
      client_id: mandatory_opt!(opts, :client_id)
    }

    {:ok, state, {:continue, {:connect, opts}}}
  end

  @impl true
  def handle_continue({:connect, opts}, %Client{} = state) do
    Logger.info("Connecting to #{state.host}:#{state.port} w/ id:#{state.client_id}")

    enhanced_state =
      state
      |> connect()
      |> init_connection(opts)
      |> start_api()

    {:noreply, enhanced_state}
  end

  @impl true
  def handle_call(:wait_for_connection, _from, %Client{} = state) do
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:req_account_summary, group, tags}, from, %Client{} = state) do
    %Client{reply_map: reply_map} = state

    Logger.debug("Requesting account summary for group: #{group}, tags: #{tags}")

    args = %{group: group, tags: tags}
    {:ok, render} = send_message(:req_account_summary, args, state)
    req_id = render.req_id

    updated_state = %Client{state | reply_map: Map.put(reply_map, req_id, from)}

    {:noreply, updated_state}
  end

  @impl true
  def handle_call({:req_market_data_type, market_data_type}, _from, %Client{} = state) do
    %Client{server_version: server_version} = state

    Logger.debug("Requesting market data type: #{market_data_type}")

    args = %{server_version: server_version, market_data_type: market_data_type}
    {:ok, _render} = send_message(:req_market_data_type, args, state)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(
        {:req_mkt_data, contract, generic_tick_list, snapshot, regulatory_snapshot, data_options},
        _from,
        %Client{} = state
      ) do
    %Client{server_version: server_version} = state

    Logger.debug("Requesting market data for contract: #{inspect(contract)}")

    args = %{
      server_version: server_version,
      contract: contract,
      generic_tick_list: generic_tick_list,
      snapshot: snapshot,
      regulatory_snapshot: regulatory_snapshot,
      data_options: data_options
    }

    {:ok, _render} = send_message(:req_mkt_data, args, state)

    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:tcp, _port, data}, %Client{} = state) do
    updated_state =
      case NetworkCodec.decode(data, state) do
        nil ->
          state

        struct ->
          Logger.debug("RECEIVED msg:#{inspect(struct)}")
          {:ok, updated_state} = Handlers.handle_message(struct, state)
          updated_state
      end

    {:noreply, updated_state}
  end

  @impl true
  def handle_info(info, %Client{} = state) do
    Logger.warning("Received info: #{inspect(info)}")
    {:noreply, state}
  end

  ## Private functions

  defp mandatory_opt!(opts, name) do
    case Keyword.fetch(opts, name) do
      {:ok, value} -> value
      :error -> {:error, "required #{name} not found in #{inspect(opts)}"}
    end
  end

  defp connect(%Client{host: host, port: port} = client) do
    host_chars = String.to_charlist(host)
    {:ok, socket} = :gen_tcp.connect(host_chars, port, [:binary, packet: 0, active: false])
    %Client{client | socket: socket}
  end

  defp init_connection(%Client{socket: socket} = client, opts) do
    timeout = Keyword.get(opts, :connection_timeout, 60_000)

    v100prefix = "API\0"
    v100version = "v#{ServerVersions.min_client_ver()}..#{ServerVersions.max_client_ver()}"

    v100version =
      case Keyword.get(opts, :connection_options) do
        nil -> v100version
        options -> [v100version, " ", options]
      end

    msg = Comm.make_msg(v100version)
    Logger.debug("msg: #{inspect(msg, binaries: :as_strings)}")
    msg2 = [v100prefix, msg]
    Logger.debug("msg2: #{inspect(msg2, binaries: :as_strings)}")
    :ok = :gen_tcp.send(socket, msg2)

    [server_version, conn_time] = get_server_version(socket, timeout)
    server_version = String.to_integer(server_version)
    Logger.debug("ANSWER Version:#{server_version} time:#{conn_time}")

    :ok = :inet.setopts(socket, active: true, packet: 4)

    # self.setConnState(EClient.CONNECTED)
    %Client{client | conn_time: conn_time, server_version: server_version}
  end

  defp get_server_version(socket, timeout) do
    {:ok, data} = :gen_tcp.recv(socket, 0, timeout)
    {size, msg, _rest = <<>>} = Comm.read_msg(data)
    Logger.debug("size:#{size} msg:#{msg}")

    fields = Comm.read_fields(msg)
    Logger.debug("fields:#{inspect(fields)}")

    # sometimes I get news before the server version, thus the loop
    case fields do
      [_server_version, _conn_time] = fields -> fields
      _ -> get_server_version(socket, timeout)
    end
  end

  defp start_api(%Client{} = client) do
    %Client{
      server_version: server_version,
      client_id: client_id,
      opt_capabilities: opt_capabilities
    } = client

    args = %{
      server_version: server_version,
      client_id: client_id,
      opt_capabilities: opt_capabilities
    }

    {:ok, _start_api} = send_message(:start_api, args, client)

    client
  end

  defp send_message(message_id, args, %Client{socket: socket} = client) do
    render = MessageViews.render(message_id, args)
    data = NetworkCodec.encode(render, client)

    Logger.debug("SENDING: #{inspect(data, binaries: :as_strings)}")
    :ok = :gen_tcp.send(socket, data)

    {:ok, render}
  end
end
