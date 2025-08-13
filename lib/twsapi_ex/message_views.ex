defmodule TWSAPIEx.MessageViews do
  @moduledoc """
  This module provides view functions for TWS API messages.
  """

  use ElvenGard.Network.View

  import TWSAPIEx.ServerVersions, only: [min_server_ver: 1]

  alias TWSAPIEx.Messages.ClientMessages.{
    ReqAccountSummary,
    ReqMarketDataType,
    StartAPI
  }

  ## View Behaviour

  @impl true
  def render(:start_api, args) do
    client_id = required_arg!(args, :client_id)
    opt_capabilities = optional_arg(args, :opt_capabilities)

    %StartAPI{client_id: client_id, opt_capabilities: opt_capabilities}
  end

  @impl true
  def render(:req_account_summary, args) do
    group = required_arg!(args, :group)
    tags = required_arg!(args, :tags)
    req_id = System.unique_integer([:positive])

    %ReqAccountSummary{req_id: req_id, group: group, tags: tags}
  end

  @impl true
  def render(:req_market_data_type, args) do
    server_version = required_arg!(args, :server_version)
    market_data_type = required_arg!(args, :market_data_type)

    if server_version < min_server_ver(:req_market_data_type) do
      raise "Unsupported server version"
    end

    %ReqMarketDataType{market_data_type: market_data_type}
  end

  @impl true
  def render(:req_mkt_data, args) do
    server_version = required_arg!(args, :server_version)
    contract = required_arg!(args, :contract)
    generic_tick_list = required_arg!(args, :generic_tick_list)
    snapshot = required_arg!(args, :snapshot)
    regulatory_snapshot = required_arg!(args, :regulatory_snapshot)
    data_options = required_arg!(args, :data_options)

    if server_version < min_server_ver(:delta_neutral) and is_def(contract.delta_neutral_contract) do
      raise "Unsupported delta-neutral orders"
    end

    if server_version < min_server_ver(:req_mkt_data_conid) and is_def(contract.con_id) do
      raise "Unsupported con_id parameter"
    end

    if server_version < min_server_ver(:trading_class) and is_def(contract.trading_class) do
      raise "Unsupported trading_class parameter in req_mkt_data"
    end

    # %ReqMktData{}
  end

  ## Private functions

  defp required_arg!(args, name) do
    case Map.fetch(args, name) do
      {:ok, value} -> value
      :error -> raise ArgumentError, "Missing required argument: #{name}"
    end
  end

  defp optional_arg(args, name) do
    Map.get(args, name)
  end

  defp is_def(value) do
    value not in [nil, "", 0]
  end
end
