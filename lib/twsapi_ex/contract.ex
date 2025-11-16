defmodule TWSAPIEx.Contract do
  @moduledoc """
  Financial instrument types used by Interactive Brokers.

  ## Security Types

  - `STK` - Stock (or ETF)
  - `OPT` - Option
  - `FUT` - Future
  - `IND` - Index
  - `FOP` - Futures option
  - `CASH` - Forex pair
  - `CFD` - CFD
  - `BAG` - Combo
  - `WAR` - Warrant
  - `BOND` - Bond
  - `CMDTY` - Commodity
  - `NEWS` - News
  - `FUND` - Mutual fund
  - `CRYPTO` - Crypto currency
  - `EVENT` - Bet on an event

  ## Examples

      # Using the generic Contract struct
      iex> %Contract{con_id: 270639}
      %Contract{con_id: 270639, sec_type: "", symbol: "", last_trade_date_or_contract_month: "", strike: 0.0, right: "", multiplier: "", exchange: "", primary_exchange: "", currency: "", local_symbol: "", trading_class: "", include_expired: false, sec_id_type: "", sec_id: "", description: "", issuer_id: "", combo_legs_descrip: "", combo_legs: [], delta_neutral_contract: nil}

      # Using helper functions
      iex> Contract.stock("AMD", "SMART", "USD")
      %Contract{sec_type: "STK", symbol: "AMD", exchange: "SMART", currency: "USD"}

      iex> Contract.forex("EURUSD")
      %Contract{sec_type: "CASH", symbol: "EUR", currency: "USD", exchange: "IDEALPRO"}

  """

  import TWSAPIEx.Enums

  alias TWSAPIEx.Enums

  defstruct sec_type: "",
            con_id: 0,
            symbol: "",
            last_trade_date_or_contract_month: "",
            strike: 0.0,
            right: "",
            multiplier: "",
            exchange: "",
            primary_exchange: "",
            currency: "",
            local_symbol: "",
            trading_class: "",
            include_expired: false,
            sec_id_type: "",
            sec_id: "",
            description: "",
            issuer_id: "",
            combo_legs_descrip: "",
            combo_legs: [],
            delta_neutral_contract: nil

  @type t :: %__MODULE__{
          sec_type: Enums.sec_type_values(),
          con_id: non_neg_integer(),
          symbol: String.t(),
          last_trade_date_or_contract_month: String.t(),
          strike: float(),
          right: Enums.right_values(),
          multiplier: String.t(),
          exchange: String.t(),
          primary_exchange: String.t(),
          currency: String.t(),
          local_symbol: String.t(),
          trading_class: String.t(),
          include_expired: boolean(),
          sec_id_type: String.t(),
          sec_id: String.t(),
          description: String.t(),
          issuer_id: String.t(),
          combo_legs_descrip: String.t(),
          combo_legs: list(),
          delta_neutral_contract: map() | nil
        }

  @doc """
  Create a stock contract.

  ## Parameters

    - `symbol` - Symbol name
    - `exchange` - Destination exchange (e.g., "SMART", "NYSE", "NASDAQ")
    - `currency` - Underlying currency (e.g., "USD", "EUR")
    - `opts` - Additional options (e.g., `primary_exchange: "NASDAQ"`)

  ## Examples

      iex> Contract.stock("AAPL", "SMART", "USD")
      %Contract{sec_type: "STK", symbol: "AAPL", exchange: "SMART", currency: "USD"}

  """
  @spec stock(String.t(), String.t(), String.t(), Keyword.t()) :: t()
  def stock(symbol, exchange, currency, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:stock, :value),
        symbol: symbol,
        exchange: exchange,
        currency: currency
      ] ++ opts
    )
  end

  @doc """
  Create an option contract.

  ## Parameters

    - `symbol` - Symbol name
    - `last_trade_date_or_contract_month` - Last trading day (YYYYMMDD) or contract month (YYYYMM)
    - `strike` - Strike price
    - `right` - Put or Call (`:put`, `:call`, "P", or "C")
    - `exchange` - Destination exchange
    - `opts` - Additional options (e.g., `multiplier: "100"`, `currency: "USD"`)

  ## Examples

      iex> Contract.option("SPY", "20231215", 450.0, :call, "SMART")
      %Contract{sec_type: "OPT", symbol: "SPY", last_trade_date_or_contract_month: "20231215", strike: 450.0, right: "C", exchange: "SMART"}

  """
  @spec option(String.t(), String.t(), float(), Enums.right(), String.t(), Keyword.t()) :: t()
  def option(symbol, last_trade_date_or_contract_month, strike, right_opt, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:option, :value),
        symbol: symbol,
        last_trade_date_or_contract_month: last_trade_date_or_contract_month,
        strike: strike,
        right: right(right_opt, :value),
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a future contract.

  ## Parameters

    - `symbol` - Symbol name
    - `last_trade_date_or_contract_month` - Last trading day (YYYYMMDD) or contract month (YYYYMM)
    - `exchange` - Destination exchange
    - `opts` - Additional options (e.g., `currency: "USD"`, `multiplier: "50"`)

  ## Examples

      iex> Contract.future("ES", "20231215", "GLOBEX")
      %Contract{sec_type: "FUT", symbol: "ES", last_trade_date_or_contract_month: "20231215", exchange: "GLOBEX"}

  """
  @spec future(String.t(), String.t(), String.t(), Keyword.t()) :: t()
  def future(symbol, last_trade_date_or_contract_month, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:future, :value),
        symbol: symbol,
        last_trade_date_or_contract_month: last_trade_date_or_contract_month,
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a continuous future contract.

  ## Parameters

    - `symbol` - Symbol name
    - `exchange` - Destination exchange
    - `opts` - Additional options (e.g., `currency: "USD"`, `local_symbol: "ESZ3"`)

  ## Examples

      iex> Contract.cont_future("ES", "GLOBEX")
      %Contract{sec_type: "CONTFUT", symbol: "ES", exchange: "GLOBEX"}

  """
  @spec cont_future(String.t(), String.t(), Keyword.t()) :: t()
  def cont_future(symbol, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:cont_future, :value),
        symbol: symbol,
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a forex pair contract.

  ## Parameters

    - `pair` - Currency pair (e.g., "EURUSD", "GBPUSD")
    - `opts` - Additional options (e.g., `exchange: "IDEALPRO"`)

  ## Examples

      iex> Contract.forex("EURUSD")
      %Contract{sec_type: "CASH", symbol: "EUR", currency: "USD", exchange: "IDEALPRO"}

  """
  @spec forex(String.t(), Keyword.t()) :: t()
  def forex(pair, opts \\ []) when byte_size(pair) == 6 do
    symbol = String.slice(pair, 0..2)
    currency = String.slice(pair, 3..5)

    enhanced_opts = Keyword.put_new(opts, :exchange, "IDEALPRO")

    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:cash, :value),
        symbol: symbol,
        currency: currency
      ] ++ enhanced_opts
    )
  end

  @doc """
  Create an index contract.

  ## Parameters

    - `symbol` - Symbol name (e.g., "SPX", "VIX")
    - `exchange` - Destination exchange
    - `opts` - Additional options (e.g., `currency: "USD"`)

  ## Examples

      iex> Contract.index("SPX", "CBOE")
      %Contract{sec_type: "IND", symbol: "SPX", exchange: "CBOE"}

  """
  @spec index(String.t(), String.t(), Keyword.t()) :: t()
  def index(symbol, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:index, :value),
        symbol: symbol,
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a CFD (Contract For Difference) contract.

  ## Parameters

    - `symbol` - Symbol name
    - `exchange` - Destination exchange
    - `opts` - Additional options (e.g., `currency: "USD"`)

  ## Examples

      iex> Contract.cfd("IBUS30", "SMART")
      %Contract{sec_type: "CFD", symbol: "IBUS30", exchange: "SMART"}

  """
  @spec cfd(String.t(), String.t(), Keyword.t()) :: t()
  def cfd(symbol, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:cfd, :value),
        symbol: symbol,
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a commodity contract.

  ## Parameters

    - `symbol` - Symbol name
    - `exchange` - Destination exchange
    - `opts` - Additional options (e.g., `currency: "USD"`)

  ## Examples

      iex> Contract.commodity("XAUUSD", "SMART")
      %Contract{sec_type: "CMDTY", symbol: "XAUUSD", exchange: "SMART"}

  """
  @spec commodity(String.t(), String.t(), Keyword.t()) :: t()
  def commodity(symbol, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:commodity, :value),
        symbol: symbol,
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a bond contract.

  ## Parameters

    - `opts` - Bond options (e.g., `sec_id_type: "ISIN"`, `sec_id: "US03076KAA60"`)

  ## Examples

      iex> Contract.bond(sec_id_type: "ISIN", sec_id: "US03076KAA60")
      %Contract{sec_type: "BOND", sec_id_type: "ISIN", sec_id: "US03076KAA60"}

  """
  @spec bond(Keyword.t()) :: t()
  def bond(opts \\ []) do
    struct!(__MODULE__, [sec_type: sec_type(:bond, :value)] ++ opts)
  end

  @doc """
  Create a futures option contract.

  ## Parameters

    - `symbol` - Symbol name
    - `last_trade_date_or_contract_month` - Last trading day (YYYYMMDD) or contract month (YYYYMM)
    - `strike` - Strike price
    - `right` - Put or Call (`:put`, `:call`, "P", or "C")
    - `exchange` - Destination exchange
    - `opts` - Additional options

  ## Examples

      iex> Contract.futures_option("ES", "20231215", 4500.0, :call, "GLOBEX")
      %Contract{sec_type: "FOP", symbol: "ES", last_trade_date_or_contract_month: "20231215", strike: 4500.0, right: "C", exchange: "GLOBEX"}

  """
  @spec futures_option(String.t(), String.t(), float(), Enums.right(), String.t(), Keyword.t()) ::
          t()
  def futures_option(
        symbol,
        last_trade_date_or_contract_month,
        strike,
        right_opt,
        exchange,
        opts \\ []
      ) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:futures_option, :value),
        symbol: symbol,
        last_trade_date_or_contract_month: last_trade_date_or_contract_month,
        strike: strike,
        right: right(right_opt, :value),
        exchange: exchange
      ] ++ opts
    )
  end

  @doc """
  Create a mutual fund contract.

  ## Parameters

    - `opts` - Fund options

  ## Examples

      iex> Contract.mutual_fund(symbol: "VFIAX")
      %Contract{sec_type: "FUND", symbol: "VFIAX"}

  """
  @spec mutual_fund(Keyword.t()) :: t()
  def mutual_fund(opts \\ []) do
    struct!(__MODULE__, [sec_type: sec_type(:fund, :value)] ++ opts)
  end

  @doc """
  Create a warrant contract.

  ## Parameters

    - `opts` - Warrant options

  ## Examples

      iex> Contract.warrant(symbol: "TSLAW")
      %Contract{sec_type: "WAR", symbol: "TSLAW"}

  """
  @spec warrant(Keyword.t()) :: t()
  def warrant(opts \\ []) do
    struct!(__MODULE__, [sec_type: sec_type(:warrant, :value)] ++ opts)
  end

  @doc """
  Create a bag (combo) contract.

  ## Parameters

    - `opts` - Bag options including `combo_legs`

  ## Examples

      iex> Contract.bag(symbol: "SPY", exchange: "SMART")
      %Contract{sec_type: "BAG", symbol: "SPY", exchange: "SMART"}

  """
  @spec bag(Keyword.t()) :: t()
  def bag(opts \\ []) do
    struct!(__MODULE__, [sec_type: sec_type(:bag, :value)] ++ opts)
  end

  @doc """
  Create a cryptocurrency contract.

  ## Parameters

    - `symbol` - Symbol name (e.g., "BTC", "ETH")
    - `exchange` - Destination exchange (e.g., "PAXOS")
    - `opts` - Additional options (e.g., `currency: "USD"`)

  ## Examples

      iex> Contract.crypto("BTC", "PAXOS")
      %Contract{sec_type: "CRYPTO", symbol: "BTC", exchange: "PAXOS"}

  """
  @spec crypto(String.t(), String.t(), Keyword.t()) :: t()
  def crypto(symbol, exchange, opts \\ []) do
    struct!(
      __MODULE__,
      [
        sec_type: sec_type(:crypto, :value),
        symbol: symbol,
        exchange: exchange
      ] ++ opts
    )
  end
end
