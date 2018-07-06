defmodule Ratelim do
  use GenServer

  @name __MODULE__

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def add_limit(id, interval, limit) do
    GenServer.cast(@name, {:add_limit, id, interval, limit})
  end

  def handle_cast({:add_limit, id, interval, limit}, state) do
    new_state =
      case state[id] do
        nil ->
          put_in(state[id], %{limits: %{interval => limit}})
        %{limits: _} ->
          update_in(state[id][:limits], &Map.put(&1, interval, limit))
      end
    {:noreply, new_state}
  end

  # def register(id, timeout \\ 0)
  # def next_available(id)
end
