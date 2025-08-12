defmodule TWSAPIEx.Decoder do
  @moduledoc """
  The Decoder knows how to transform a message's payload into higher level
  IB message (eg: order info, mkt data, etc).
  It will call the corresponding method from the EWrapper so that customer's code
  (eg: class derived from EWrapper) can make further use of the data.
  """
end
