defmodule TWSAPIEx.MessageViews do
  @moduledoc """
  This module provides view functions for TWS API messages.
  """

  use ElvenGard.Network.View

  require TWSAPIEx.ServerVersions, as: ServerVersions

  alias TWSAPIEx.Messages.ClientMessages.{
    ReqAccountSummary,
    StartAPI,
    StartAPIOld
  }

  ## View Behaviour

  @impl true
  def render(:start_api, args) do
    server_version = required_arg!(args, :server_version)
    version = optional_arg(args, :version)
    client_id = required_arg!(args, :client_id)
    opt_capabilities = optional_arg(args, :opt_capabilities)

    if server_version >= ServerVersions.min_server_ver(:optional_capabilities) do
      %StartAPI{version: version, client_id: client_id, opt_capabilities: opt_capabilities}
    else
      %StartAPIOld{version: version, client_id: client_id}
    end
  end

  @impl true
  def render(:req_account_summary, args) do
    version = optional_arg(args, :version)
    group = required_arg!(args, :group)
    tags = required_arg!(args, :tags)
    req_id = System.unique_integer([:positive])

    %ReqAccountSummary{version: version, req_id: req_id, group: group, tags: tags}
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
end
