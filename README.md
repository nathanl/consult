# Consult

NOTHING TO SEE HERE (yet).

## Aspirations

Consult lets you easily add live chat to a Phoenix app, where customers can get help from support staff.

## Requirements

Technically, Consult requires:

- Phoenix
- Ecto
- An Ecto-supported relational database (like PostgreSQL) and a few tables therein (see `mix consult.show_expected_structure`.

Also, Consult needs to know a little about your application. See the Configuration section below.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `consult` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:consult, "~> 0.0.1"}]
    end
    ```

  2. `mix deps.get`

  3.  Add `:consult` to your list of applications in `def application`.

##  Setup

### Tables

Consult requires some database tables for conversations, messages, and associated data.

Run `mix consult.show_expected_structure` to see an example migration that would add the tables it needs, then either create and run an identical migration, or write your own migration to make your schema match the one shown.

### Router and Endpoint

To your Phoenix routes file, add this:

```elixir
forward "/consult", Consult.Routes
```

To your Endpoint, add this:

```elixir
use Consult.Socket
```

In your Mix configuration (eg, `config.exs` or an environment-specific one), add lines like the following, referencing your own endpoint and ecto Repo modules:

```elixir
config :consult, :endpoint, MyApp.Endpoint
config :consult, :repo, MyApp.Repo
config :consult, :hooks_module, MyApp.ConsultHooks
```

The hooks module referenced in the configuration must define the following functions:

- `user_for_request(conn)` - must return a map or struct representing the user for the current request. `user.id` and `user.name` are required fields, but both can have `nil` values if (for instance) the user is not logged in.
- `representative?(user)` accepts one of the user maps returned by `user_for_request(conn)` and returns a boolean, answering the question "is this person allowed to function as a customer service representative - for example, to answer user chat requests?"

Here's the simplest possible implementation:

```elixir
defmodule MyApp.ConsultHooks do

  def user_for_request(_conn) do
    # doesn't bother checking session, so
    # all chat users are anonymous
    %{id: nil, name: nil}
  end

  # 'user' is a return value from 'user_for_request'
  def representative?(_user) do
    # doesn't bother inspecting user, so all users
    # can see and answer incoming user chats
    # in the customer support dashboard
    true
  end

end
```

### Templates

Wherever you'd like to display a chatbox in your template, use:

```eex
<%= render Consult.ChatboxView, "_chatbox.html" %>
```

### Brunch and Assets

Note: this is the part that I understand least, because Brunch. 😆 But I think this will work.

In your Phoenix app's brunch config

- Add this to your `watched` section `"deps/consult/web/static"`
- To the `stylesheets.order` section, add `before: ["deps/consult/web/static/css/consult.css"]`

In your Javascript, do this:

```javascript
import {Socket} from "phoenix"
import {Consult} from "consult"
let consult = new Consult(Socket)
consult.enable()
```

## Usage

Users can start chats from anywhere you put the chat box.

Representatives can answer chats in the customer support dashboard at `/consult/conversations`.
