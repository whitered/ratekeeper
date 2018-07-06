# Ratekeeper

Ratekeeper allows you to rate limit calls to external API or anything else.
It supports complex rate limits and estimates time left to reset limits.

## Usage

Set the limits:
```elixir
iex(1)> Ratekeeper.add_limit "api.org", 1000, 1
:ok
iex(2)> Ratekeeper.add_limit "api.org", 60_000, 5
:ok
```
Here we set 2 limits: 1 request per second and 5 requests / minute.

Now you should appoint your rate limited request with
Ratekeeper.register:

```elixir
case Ratekeeper.register("api.org", 60_000) do
  nil -> raise "Request not allowed in the next 60 seconds"
  delay ->
    :timer.sleep(delay)
    make_request("http://api.org/stop?limiting=me")
end
```

To only check time left to when new request can be made:
```elixir
iex(3)> Ratekeeper.time_to_wait "api.org"
49027
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ratelim` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ratekeeper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at
[https://hexdocs.pm/ratekeeper](https://hexdocs.pm/ratekeeper).

