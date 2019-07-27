defmodule WE.Helpers do
  @spec ok_tuple(any) :: {:ok, any}
  def ok_tuple(val) do
    case val do
      {:error, _} -> val
      _ -> {:ok, val}
    end
  end

  @spec unpack_ok_tuple(any) :: any
  def unpack_ok_tuple({:ok, val}) do
    val
  end

  def unpack_ok_tuple(val) do
    val
  end

  @spec unpack_engine_tuple(any) :: any
  def unpack_engine_tuple({:ok, engine, _val}) do
    engine
  end

  def unpack_engine_tuple(val) do
    val
  end

  @spec unpack_engine_tuple_value(any) :: any
  def unpack_engine_tuple_value({:ok, _engine, val}) do
    val
  end

  def unpack_engine_tuple_value(val) do
    val
  end

  @spec id :: String.t()
  def id() do
    Base.encode64(:crypto.strong_rand_bytes(16), padding: false)
  end
end
