# Ratekeeper

Ratekeeper is a library to schedule rate-limited actions.
It supports complex rate limits and estimates time left to reset limits.


## Installation

Add `ratekeeper` as dependency in `mix.exs`

``` elixir
def deps do
    [{:ratekeeper, "~> 0.1.0"}]
end
```

## Usage


Limits can be set in config:
```
config :ratekeeper, :limits, %{"myapi.org" => [{1000, 5}, {60000, 100}]}
```
or at runtime:
```
Ratekeeper.add_limit "myapi.org", 1000, 5
Ratekeeper.add_limit "myapi.org", 60000, 100
```
This sets limits to 5 requests per 1 second and 100 requests per minute.

To check time to release rate limits:
```
Ratekeeper.time_to_wait "myapi.org"
```

To appoint a request to rate limited api:
```
case Ratekeeper.register("myapi.org", 10_000) do
  nil -> raise "Rate limits exceeded, request not allowed in next 10 seconds"
  delay ->
    :timer.sleep(delay)
    MyApi.do_request()
end
```


The docs can be found at [https://hexdocs.pm/ratekeeper](https://hexdocs.pm/ratekeeper).

