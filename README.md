# HackerNewsAggregator

Elixir aggregator for Hacker News top stories using GenServer as state and
supporting REST APIs and websockets to retrieve top stories

> Websockets integrations thanks to: https://medium.com/@loganbbres/elixir-websocket-chat-example-c72986ab5778

## Prerequisities
If you want to see the websocket working I recommend installing a client like
`wscat`

```
npm install -g wscat
```

## Installation
```
mix deps.get
mix compile
```

## Start the application
```
mix run
# or
iex -S mix run
```

## Configurations
See `config/config.exs`

`max_amount`: setup how many *top stories* the application will
saved in the state

`countdown`: set the interval to update the list of *top stories*

## Examples

```
# Fetch `max_amount` of top stories from the state with default pagination
# (page_size: 10, page_number: 1)
  curl 'http://localhost:4001/top_stories'
```

```
# Fetch `max_amount` of top stories from the state with custom pagination
  curl 'http://localhost:4001/top_stories?page_number=2&page_size=5'
```

```
# Fetch a single story from the state (or HackerNews) by ID
  curl 'http://localhost:4001/story?id=2773458'
```

```
# Start listening to top stories
  wscat -c ws://localhost:4001/ws
```
