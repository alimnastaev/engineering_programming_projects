defmodule Colors do
  @moduledoc false

  def red(), do: IO.ANSI.red()

  def yellow(), do: IO.ANSI.yellow()

  def reset(), do: IO.ANSI.reset()
end
