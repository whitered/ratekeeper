defmodule Ratekeeper.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Ratekeeper
    ]

    opts = [strategy: :one_for_one, name: Ratekeeper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
