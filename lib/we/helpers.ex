defmodule WE.Helpers do
  @spec ok_tuple(any) :: {:ok, any}
  def ok_tuple(val) do
    {:ok, val}
  end

  @spec unpack_ok_tuple(any) :: any
  def unpack_ok_tuple({:ok, val}) do
    val
  end

  def unpack_ok_tuple(val) do
    val
  end
end
