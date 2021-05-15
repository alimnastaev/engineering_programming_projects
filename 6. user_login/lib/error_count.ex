defmodule ErrorCounter do
  use Agent

  def start(), do: Agent.start_link(fn -> 3 end, name: :error_counter)

  def update(),
    do: Agent.update(:error_counter, &(&1 - 1))

  def get(), do: Agent.get(:error_counter, & &1)

  def stop(), do: Agent.stop(:error_counter)
end
