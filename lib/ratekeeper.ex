defmodule Ratekeeper do
  use GenServer

  @name __MODULE__

  ## Client API

  def start_link(limits) do
    GenServer.start_link(__MODULE__, [limits], name: @name)
  end

  def add_limit(id, interval, limit) when interval > 0 and limit > 0 do
    GenServer.cast(@name, {:add_limit, id, interval, limit})
  end

  def delete_limit(id, interval) do
    GenServer.cast(@name, {:delete_limit, id, interval})
  end

  def reset_hits(id) do
    GenServer.cast(@name, {:reset_hits, id})
  end

  def time_to_wait(id) do
    GenServer.call(@name, {:time_to_wait, id})
  end

  def register(id, max_waiting_time \\ 0) do
    GenServer.call(@name, {:register, id, max_waiting_time})
  end

  ## Server Callbacks

  def init([arg]) do
    {:ok, read_limits(arg)}
  end

  def handle_cast({:add_limit, id, interval, limit}, state) do
    new_state =
      case state[id] do
        nil ->
          put_in(state[id], %{intervals: %{interval => {limit, limit}}, last_hit: current_time()})
        _ ->
          update_intervals = fn map ->
            Map.update(map, interval, {limit, limit}, fn {_old_lim, hits} -> {limit, hits} end)
          end
          update_in(state[id][:intervals], update_intervals)
      end
    {:noreply, new_state}
  end

  def handle_cast({:delete_limit, id, interval}, state) do
    new_state =
      case state[id] do
        nil -> state
        _ -> pop_in(state[id][:intervals][interval]) |> elem(1)
      end
    {:noreply, new_state}
  end

  def handle_cast({:reset_hits, id}, state) do
    new_state = 
      case state[id] do
        nil -> state
        _ ->
          update_intervals = fn map ->
            map
            |> Enum.map(fn {interval, {limit, _hits}} -> {interval, {limit, 0}} end)
            |> Map.new()
          end
          update_in(state[id][:intervals], update_intervals)
      end
    {:noreply, new_state}
  end

  def handle_call({:time_to_wait, id}, _from, state) do
    case state[id] do
      nil -> {:reply, 0, state}
      bucket ->
        now = current_time()
        ttw =
          bucket
          |> next_available_time(now)
          |> get_delay(now)
        {:reply, ttw, state}
    end
  end

  def handle_call({:register, id, max_waiting_time}, _from, state) do
    case state[id] do
      nil -> {:reply, 0, state}
      bucket ->
        now = current_time()
        time = next_available_time(bucket, now)
        delay = get_delay(time, now)
        case delay <= max_waiting_time do
          true ->
            new_state = Map.put(state, id, register_hit(bucket, time))
            {:reply, delay, new_state}
          false ->
            {:reply, nil, state}
        end
    end
  end

  ## implementation

  defp read_limits(arg) do
    arg
    |> Enum.map(fn {id, limits} -> {id, %{intervals: build_intervals(limits), last_hit: current_time()}} end)
    |> Map.new
  end

  defp build_intervals(limits) do
    limits
    |> Enum.map(fn {interval, limit} -> {interval, {limit, limit}} end)
    |> Map.new
  end

  if Mix.env == :test do
    @now :os.system_time(:millisecond)
    defp current_time, do: @now
  else
    defp current_time, do: :os.system_time(:millisecond)
  end

  defp next_available_time(bucket, current_time) do
    bucket
    |> get_filled_intervals()
    |> get_next_available(bucket[:last_hit])
    |> max(current_time)
  end

  defp get_delay(time, current_time) do
    max(0, time - current_time)
  end

  defp get_filled_intervals(%{intervals: intervals}) do
    intervals
    |> Enum.filter(fn {_interval, {limit, hits}} -> hits >= limit end)
    |> Enum.map(&elem(&1, 0))
  end

  defp get_next_available([], last_hit), do: last_hit
  defp get_next_available(filled_intervals, last_hit) do
    filled_intervals
    |> Enum.map(&((div(last_hit, &1) + 1) * &1))
    |> Enum.max
  end

  defp register_hit(%{last_hit: last_hit, intervals: intervals}, time) do
    update_hits = fn {interval, {limit, hits}} ->
      case div(last_hit, interval) == div(time, interval) do
        true -> {interval, {limit, hits + 1}}
        false -> {interval, {limit, 1}}
      end
    end
    new_intervals =
      intervals
      |> Enum.map(update_hits)
      |> Map.new()
    %{last_hit: time, intervals: new_intervals}
  end
end
