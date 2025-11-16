defmodule TWSAPIEx.Enums do
  @moduledoc """
  Enumerations for IBKR fixed values.
  """

  import SimpleEnum, only: [defenum: 2]

  # Security types
  defenum :sec_type,
    stock: "STK",
    option: "OPT",
    future: "FUT",
    cont_future: "CONTFUT",
    cash: "CASH",
    index: "IND",
    cfd: "CFD",
    bag: "BAG",
    warrant: "WAR",
    bond: "BOND",
    commodity: "CMDTY",
    news: "NEWS",
    fund: "FUND",
    crypto: "CRYPTO",
    event: "EVENT",
    futures_option: "FOP"

  # Order actions
  defenum :action,
    buy: "BUY",
    sell: "SELL"

  # Order types
  defenum :order_type,
    market: "MKT",
    limit: "LMT",
    stop: "STP",
    stop_limit: "STP LMT",
    trailing_stop: "TRAIL",
    market_on_close: "MOC",
    limit_on_close: "LOC",
    pegged_to_market: "PEG MKT",
    relative: "REL",
    box_top: "BOX TOP",
    limit_if_touched: "LIT",
    market_if_touched: "MIT",
    market_to_limit: "MTL",
    midprice: "MIDPRICE"

  # Time in force
  defenum :tif,
    day: "DAY",
    gtc: "GTC",
    ioc: "IOC",
    gtd: "GTD",
    opg: "OPG",
    fok: "FOK",
    dth: "DTC"

  # Option rights
  defenum :right,
    put: "P",
    call: "C",
    none: ""

  # Order status
  defenum :order_status,
    pending_submit: "PendingSubmit",
    pending_cancel: "PendingCancel",
    pre_submitted: "PreSubmitted",
    submitted: "Submitted",
    api_pending: "ApiPending",
    api_cancelled: "ApiCancelled",
    api_update: "ApiUpdate",
    cancelled: "Cancelled",
    filled: "Filled",
    inactive: "Inactive",
    validation_error: "ValidationError"
end
