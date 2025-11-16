defmodule TWSAPIEx.Objects do
  @moduledoc """
  Object hierarchy for Interactive Brokers data structures.

  This module contains various data structures returned by TWS/IBKR Gateway:

    - Account information (AccountValue, Position, PortfolioItem)
    - Execution data (Execution, CommissionReport, Fill)
    - Market data (BarData, RealTimeBar, TickData)
    - Order status (OrderStatus, OrderState)

  """

  # ========== Account Information ==========

  defmodule AccountValue do
    @moduledoc """
    Account value information.

    Contains a single account attribute (tag) with its value.
    """

    defstruct [:account, :tag, :value, :currency, :model_code]

    @type t :: %__MODULE__{
            account: String.t(),
            tag: String.t(),
            value: String.t(),
            currency: String.t(),
            model_code: String.t()
          }
  end

  defmodule Position do
    @moduledoc """
    Position information for a contract.

    Represents a position in a specific account.
    """

    alias TWSAPIEx.Contract

    defstruct [:account, :contract, :position, :avg_cost]

    @type t :: %__MODULE__{
            account: String.t(),
            contract: Contract.t(),
            position: float(),
            avg_cost: float()
          }
  end

  defmodule PortfolioItem do
    @moduledoc """
    Portfolio item with P&L information.

    Extended position information including market value and unrealized P&L.
    """

    alias TWSAPIEx.Contract

    defstruct [
      :contract,
      :position,
      :market_price,
      :market_value,
      :average_cost,
      :unrealized_pnl,
      :realized_pnl,
      :account
    ]

    @type t :: %__MODULE__{
            contract: Contract.t(),
            position: float(),
            market_price: float(),
            market_value: float(),
            average_cost: float(),
            unrealized_pnl: float(),
            realized_pnl: float(),
            account: String.t()
          }
  end

  defmodule PnL do
    @moduledoc """
    Profit and Loss information.
    """

    defstruct account: "",
              model_code: "",
              daily_pnl: nil,
              unrealized_pnl: nil,
              realized_pnl: nil

    @type t :: %__MODULE__{
            account: String.t(),
            model_code: String.t(),
            daily_pnl: float() | nil,
            unrealized_pnl: float() | nil,
            realized_pnl: float() | nil
          }
  end

  defmodule PnLSingle do
    @moduledoc """
    Single position Profit and Loss information.
    """

    defstruct account: "",
              model_code: "",
              con_id: 0,
              daily_pnl: nil,
              unrealized_pnl: nil,
              realized_pnl: nil,
              position: 0,
              value: nil

    @type t :: %__MODULE__{
            account: String.t(),
            model_code: String.t(),
            con_id: non_neg_integer(),
            daily_pnl: float() | nil,
            unrealized_pnl: float() | nil,
            realized_pnl: float() | nil,
            position: integer(),
            value: float() | nil
          }
  end

  # ========== Execution Information ==========

  defmodule Execution do
    @moduledoc """
    Execution details for a filled order.

    Contains information about a trade execution.
    """

    defstruct exec_id: "",
              time: nil,
              acct_number: "",
              exchange: "",
              side: "",
              shares: 0.0,
              price: 0.0,
              perm_id: 0,
              client_id: 0,
              order_id: 0,
              liquidation: 0,
              cum_qty: 0.0,
              avg_price: 0.0,
              order_ref: "",
              ev_rule: "",
              ev_multiplier: 0.0,
              model_code: "",
              last_liquidity: 0,
              pending_price_revision: false

    @type t :: %__MODULE__{
            exec_id: String.t(),
            time: DateTime.t() | nil,
            acct_number: String.t(),
            exchange: String.t(),
            side: TWSAPIEx.Enums.action_values(),
            shares: float(),
            price: float(),
            perm_id: non_neg_integer(),
            client_id: non_neg_integer(),
            order_id: non_neg_integer(),
            liquidation: non_neg_integer(),
            cum_qty: float(),
            avg_price: float(),
            order_ref: String.t(),
            ev_rule: String.t(),
            ev_multiplier: float(),
            model_code: String.t(),
            last_liquidity: non_neg_integer(),
            pending_price_revision: boolean()
          }
  end

  defmodule CommissionReport do
    @moduledoc """
    Commission report for an execution.

    Contains commission and P&L information for a trade.
    """

    defstruct exec_id: "",
              commission: 0.0,
              currency: "",
              realized_pnl: 0.0,
              yield: 0.0,
              yield_redemption_date: 0

    @type t :: %__MODULE__{
            exec_id: String.t(),
            commission: float(),
            currency: String.t(),
            realized_pnl: float(),
            yield: float(),
            yield_redemption_date: non_neg_integer()
          }
  end

  defmodule Fill do
    @moduledoc """
    Fill information combining execution and commission.

    A complete record of a trade including contract, execution, and commission.
    """

    alias TWSAPIEx.Contract

    defstruct [:contract, :execution, :commission_report, :time]

    @type t :: %__MODULE__{
            contract: Contract.t(),
            execution: Execution.t(),
            commission_report: CommissionReport.t(),
            time: DateTime.t() | nil
          }
  end

  defmodule ExecutionFilter do
    @moduledoc """
    Execution filter for querying executions.
    """

    defstruct client_id: 0,
              acct_code: "",
              time: "",
              symbol: "",
              sec_type: "",
              exchange: "",
              side: ""

    @type t :: %__MODULE__{
            client_id: non_neg_integer(),
            acct_code: String.t(),
            time: String.t(),
            symbol: String.t(),
            sec_type: TWSAPIEx.Enums.sec_type_values(),
            exchange: String.t(),
            side: TWSAPIEx.Enums.action_values()
          }
  end

  # ========== Market Data ==========

  defmodule BarData do
    @moduledoc """
    Historical bar data (OHLCV).

    Represents a single bar of historical market data.
    """

    defstruct date: nil,
              open: 0.0,
              high: 0.0,
              low: 0.0,
              close: 0.0,
              volume: 0.0,
              average: 0.0,
              bar_count: 0

    @type t :: %__MODULE__{
            date: Date.t() | DateTime.t() | nil,
            open: float(),
            high: float(),
            low: float(),
            close: float(),
            volume: float(),
            average: float(),
            bar_count: non_neg_integer()
          }
  end

  defmodule RealTimeBar do
    @moduledoc """
    Real-time bar data (5-second bars).

    Live streaming bar data updated every 5 seconds.
    """

    defstruct time: nil,
              end_time: -1,
              open: 0.0,
              high: 0.0,
              low: 0.0,
              close: 0.0,
              volume: 0.0,
              wap: 0.0,
              count: 0

    @type t :: %__MODULE__{
            time: DateTime.t() | nil,
            end_time: integer(),
            open: float(),
            high: float(),
            low: float(),
            close: float(),
            volume: float(),
            wap: float(),
            count: non_neg_integer()
          }
  end

  defmodule TickData do
    @moduledoc """
    Tick data point.

    A single market data tick (price or size update).
    """

    defstruct [:time, :tick_type, :price, :size]

    @type t :: %__MODULE__{
            time: DateTime.t() | nil,
            tick_type: non_neg_integer(),
            price: float(),
            size: float()
          }
  end

  defmodule HistoricalTick do
    @moduledoc """
    Historical tick data.
    """

    defstruct [:time, :price, :size]

    @type t :: %__MODULE__{
            time: DateTime.t() | nil,
            price: float(),
            size: float()
          }
  end

  # ========== Order Status ==========

  defmodule OrderStatus do
    @moduledoc """
    Order status information.

    Contains the current state and fill information for an order.

    ## Order States

    - `PendingSubmit` - Order is being submitted
    - `PendingCancel` - Order is being cancelled
    - `PreSubmitted` - Order has been pre-submitted
    - `Submitted` - Order has been submitted
    - `ApiPending` - API order is pending
    - `ApiCancelled` - API order has been cancelled
    - `Cancelled` - Order has been cancelled
    - `Filled` - Order has been filled
    - `Inactive` - Order is inactive

    """

    defstruct order_id: 0,
              status: "",
              filled: 0.0,
              remaining: 0.0,
              avg_fill_price: 0.0,
              perm_id: 0,
              parent_id: 0,
              last_fill_price: 0.0,
              client_id: 0,
              why_held: "",
              mkt_cap_price: 0.0

    @type t :: %__MODULE__{
            order_id: non_neg_integer(),
            status: TWSAPIEx.Enums.order_status_values(),
            filled: float(),
            remaining: float(),
            avg_fill_price: float(),
            perm_id: non_neg_integer(),
            parent_id: non_neg_integer(),
            last_fill_price: float(),
            client_id: non_neg_integer(),
            why_held: String.t(),
            mkt_cap_price: float()
          }

    @doc """
    Get the total size of the order.
    """
    @spec total(t()) :: float()
    def total(%__MODULE__{filled: filled, remaining: remaining}) do
      filled + remaining
    end

    @doc """
    Check if the order is in a done state (filled, cancelled, or inactive).
    """
    @spec done?(t()) :: boolean()
    def done?(%__MODULE__{status: status}) do
      status in ["Filled", "Cancelled", "ApiCancelled", "Inactive"]
    end

    @doc """
    Check if the order is active (capable of executing).
    """
    @spec active?(t()) :: boolean()
    def active?(%__MODULE__{status: status}) do
      status in [
        "PendingSubmit",
        "ApiPending",
        "PreSubmitted",
        "Submitted",
        "ValidationError",
        "ApiUpdate"
      ]
    end

    @doc """
    Check if the order is working (live at the exchange).
    """
    @spec working?(t()) :: boolean()
    def working?(%__MODULE__{status: status}) do
      status in ["Submitted", "ValidationError", "ApiUpdate"]
    end
  end

  defmodule OrderState do
    @moduledoc """
    Order state with margin and commission information.

    Contains additional order state details including margin requirements.
    """

    @unset_double 1.7_976_931_348_623_157e308

    defstruct status: "",
              init_margin_before: "",
              maint_margin_before: "",
              equity_with_loan_before: "",
              init_margin_change: "",
              maint_margin_change: "",
              equity_with_loan_change: "",
              init_margin_after: "",
              maint_margin_after: "",
              equity_with_loan_after: "",
              commission: @unset_double,
              min_commission: @unset_double,
              max_commission: @unset_double,
              commission_currency: "",
              warning_text: "",
              completed_time: "",
              completed_status: ""

    @type t :: %__MODULE__{
            status: TWSAPIEx.Enums.order_status_values(),
            init_margin_before: String.t(),
            maint_margin_before: String.t(),
            equity_with_loan_before: String.t(),
            init_margin_change: String.t(),
            maint_margin_change: String.t(),
            equity_with_loan_change: String.t(),
            init_margin_after: String.t(),
            maint_margin_after: String.t(),
            equity_with_loan_after: String.t(),
            commission: float(),
            min_commission: float(),
            max_commission: float(),
            commission_currency: String.t(),
            warning_text: String.t(),
            completed_time: String.t(),
            completed_status: String.t()
          }
  end

  # ========== Other Structures ==========

  defmodule SoftDollarTier do
    @moduledoc """
    Soft dollar tier information.
    """

    defstruct name: "", val: "", display_name: ""

    @type t :: %__MODULE__{
            name: String.t(),
            val: String.t(),
            display_name: String.t()
          }

    @doc """
    Check if the soft dollar tier is empty.
    """
    @spec empty?(t()) :: boolean()
    def empty?(%__MODULE__{name: "", val: "", display_name: ""}), do: true
    def empty?(_), do: false
  end

  defmodule NewsProvider do
    @moduledoc """
    News provider information.
    """

    defstruct code: "", name: ""

    @type t :: %__MODULE__{
            code: String.t(),
            name: String.t()
          }
  end

  defmodule HistogramData do
    @moduledoc """
    Histogram data point.
    """

    defstruct price: 0.0, count: 0

    @type t :: %__MODULE__{
            price: float(),
            count: non_neg_integer()
          }
  end
end
