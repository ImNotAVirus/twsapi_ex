defmodule TWSAPIEx.Order do
  @moduledoc """
  Order types used by Interactive Brokers.

  ## Order Types

  - `MKT` - Market order
  - `LMT` - Limit order
  - `STP` - Stop order
  - `STP LMT` - Stop limit order
  - `TRAIL` - Trailing stop order

  ## Actions

  - `:buy` - Buy order
  - `:sell` - Sell order

  ## Time in Force

  - `:day` - Day order
  - `:gtc` - Good till cancelled
  - `:ioc` - Immediate or cancel
  - `:gtd` - Good till date

  ## Examples

      # Market order
      iex> Order.market_order(:buy, 100)
      %Order{order_type: "MKT", action: "BUY", total_quantity: 100.0}

      # Limit order
      iex> Order.limit_order(:buy, 100, 150.50)
      %Order{order_type: "LMT", action: "BUY", lmt_price: 150.50, total_quantity: 100.0}

  See: https://interactivebrokers.github.io/tws-api/available_orders.html

  """

  import TWSAPIEx.Enums

  alias TWSAPIEx.Enums

  @unset_double 1.7_976_931_348_623_157e308
  @unset_integer 2_147_483_647

  defstruct order_id: 0,
            client_id: 0,
            perm_id: 0,
            action: "",
            total_quantity: 0.0,
            order_type: "",
            lmt_price: @unset_double,
            aux_price: @unset_double,
            tif: "",
            active_start_time: "",
            active_stop_time: "",
            oca_group: "",
            oca_type: 0,
            order_ref: "",
            transmit: true,
            parent_id: 0,
            block_order: false,
            sweep_to_fill: false,
            display_size: 0,
            trigger_method: 0,
            outside_rth: false,
            hidden: false,
            good_after_time: "",
            good_till_date: "",
            all_or_none: false,
            min_qty: @unset_integer,
            percent_offset: @unset_double,
            trail_stop_price: @unset_double,
            trailing_percent: @unset_double,
            account: "",
            what_if: false,
            not_held: false,
            model_code: "",
            cash_qty: @unset_double

  @type t :: %__MODULE__{
          order_id: non_neg_integer(),
          client_id: non_neg_integer(),
          perm_id: non_neg_integer(),
          action: Enums.action_values(),
          total_quantity: float(),
          order_type: String.t(),
          lmt_price: float(),
          aux_price: float(),
          tif: Enums.tif_values(),
          active_start_time: String.t(),
          active_stop_time: String.t(),
          oca_group: String.t(),
          oca_type: non_neg_integer(),
          order_ref: String.t(),
          transmit: boolean(),
          parent_id: non_neg_integer(),
          block_order: boolean(),
          sweep_to_fill: boolean(),
          display_size: non_neg_integer(),
          trigger_method: non_neg_integer(),
          outside_rth: boolean(),
          hidden: boolean(),
          good_after_time: String.t(),
          good_till_date: String.t(),
          all_or_none: boolean(),
          min_qty: integer(),
          percent_offset: float(),
          trail_stop_price: float(),
          trailing_percent: float(),
          account: String.t(),
          what_if: boolean(),
          not_held: boolean(),
          model_code: String.t(),
          cash_qty: float()
        }

  @doc """
  Create a market order.

  A market order is an order to buy or sell at the current market price.

  ## Parameters

    - `action` - `:buy` or `:sell`
    - `quantity` - Number of shares/contracts
    - `opts` - Additional options (e.g., `tif: :day`, `outside_rth: true`)

  ## Examples

      iex> Order.market_order(:buy, 100)
      %Order{order_type: "MKT", action: "BUY", total_quantity: 100.0}

  """
  @spec market_order(Enums.action(), number(), Keyword.t()) :: t()
  def market_order(action, quantity, opts \\ []) do
    struct!(
      __MODULE__,
      [
        order_type: "MKT",
        action: action(action, :value),
        total_quantity: to_float(quantity)
      ] ++ normalize_opts(opts)
    )
  end

  @doc """
  Create a limit order.

  A limit order is an order to buy or sell at a specified price or better.

  ## Parameters

    - `action` - `:buy` or `:sell`
    - `quantity` - Number of shares/contracts
    - `limit_price` - Maximum price for buy, minimum price for sell
    - `opts` - Additional options (e.g., `tif: :day`)

  ## Examples

      iex> Order.limit_order(:buy, 100, 150.50)
      %Order{order_type: "LMT", action: "BUY", lmt_price: 150.50, total_quantity: 100.0}

  """
  @spec limit_order(Enums.action(), number(), float(), Keyword.t()) :: t()
  def limit_order(action, quantity, limit_price, opts \\ []) do
    struct!(
      __MODULE__,
      [
        order_type: "LMT",
        action: action(action, :value),
        total_quantity: to_float(quantity),
        lmt_price: limit_price
      ] ++ normalize_opts(opts)
    )
  end

  @doc """
  Create a stop order.

  A stop order becomes a market order once the stop price is reached.

  ## Parameters

    - `action` - `:buy` or `:sell`
    - `quantity` - Number of shares/contracts
    - `stop_price` - Price at which the order becomes active
    - `opts` - Additional options (e.g., `tif: :day`)

  ## Examples

      iex> Order.stop_order(:sell, 100, 145.00)
      %Order{order_type: "STP", action: "SELL", aux_price: 145.00, total_quantity: 100.0}

  """
  @spec stop_order(Enums.action(), number(), float(), Keyword.t()) :: t()
  def stop_order(action, quantity, stop_price, opts \\ []) do
    struct!(
      __MODULE__,
      [
        order_type: "STP",
        action: action(action, :value),
        total_quantity: to_float(quantity),
        aux_price: stop_price
      ] ++ normalize_opts(opts)
    )
  end

  @doc """
  Create a stop limit order.

  A stop limit order becomes a limit order once the stop price is reached.

  ## Parameters

    - `action` - `:buy` or `:sell`
    - `quantity` - Number of shares/contracts
    - `stop_price` - Price at which the order becomes active
    - `limit_price` - Maximum price for buy, minimum price for sell once activated
    - `opts` - Additional options (e.g., `tif: :day`)

  ## Examples

      iex> Order.stop_limit_order(:sell, 100, 145.00, 144.50)
      %Order{order_type: "STP LMT", action: "SELL", aux_price: 145.00, lmt_price: 144.50, total_quantity: 100.0}

  """
  @spec stop_limit_order(Enums.action(), number(), float(), float(), Keyword.t()) :: t()
  def stop_limit_order(action, quantity, stop_price, limit_price, opts \\ []) do
    struct!(
      __MODULE__,
      [
        order_type: "STP LMT",
        action: action(action, :value),
        total_quantity: to_float(quantity),
        lmt_price: limit_price,
        aux_price: stop_price
      ] ++ normalize_opts(opts)
    )
  end

  @doc """
  Create a trailing stop order.

  A trailing stop order maintains a stop price that moves with the market price.

  ## Parameters

    - `action` - `:buy` or `:sell`
    - `quantity` - Number of shares/contracts
    - `trailing_percent` - Trailing percentage (e.g., 2.0 for 2%)
    - `opts` - Additional options (e.g., `tif: :day`, `trail_stop_price: 150.0`)

  ## Examples

      iex> Order.trailing_stop_order(:sell, 100, 2.0)
      %Order{order_type: "TRAIL", action: "SELL", trailing_percent: 2.0, total_quantity: 100.0}

  """
  @spec trailing_stop_order(Enums.action(), number(), float(), Keyword.t()) :: t()
  def trailing_stop_order(action, quantity, trailing_percent, opts \\ []) do
    struct!(
      __MODULE__,
      [
        order_type: "TRAIL",
        action: action(action, :value),
        total_quantity: to_float(quantity),
        trailing_percent: trailing_percent
      ] ++ normalize_opts(opts)
    )
  end

  @doc """
  Check if a numeric value is unset (IBKR's sentinel value).

  ## Examples

      iex> Order.unset_double?(1.7976931348623157e308)
      true
      iex> Order.unset_double?(150.50)
      false

  """
  @spec unset_double?(float()) :: boolean()
  def unset_double?(value), do: value == @unset_double

  @doc """
  Check if an integer value is unset (IBKR's sentinel value).

  ## Examples

      iex> Order.unset_integer?(2_147_483_647)
      true
      iex> Order.unset_integer?(100)
      false

  """
  @spec unset_integer?(integer()) :: boolean()
  def unset_integer?(value), do: value == @unset_integer

  @doc """
  Get the unset double sentinel value used by IBKR.

  ## Examples

      iex> Order.unset_double()
      1.7976931348623157e308

  """
  @spec unset_double() :: float()
  def unset_double, do: @unset_double

  @doc """
  Get the unset integer sentinel value used by IBKR.

  ## Examples

      iex> Order.unset_integer()
      2_147_483_647

  """
  @spec unset_integer() :: integer()
  def unset_integer, do: @unset_integer

  # Private helpers

  @spec to_float(number()) :: float()
  defp to_float(value) when is_integer(value), do: value * 1.0
  defp to_float(value) when is_float(value), do: value

  @spec normalize_opts(Keyword.t()) :: Keyword.t()
  defp normalize_opts(opts) do
    Enum.map(opts, fn
      {:tif, tif_value} -> {:tif, tif(tif_value, :value)}
      other -> other
    end)
  end
end
