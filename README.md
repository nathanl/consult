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
      [{:consult, "~> 0.1.0"}]
    end
    ```

  2. Ensure `consult` is started before your application:

    ```elixir
    def application do
      [applications: [:consult]]
    end
    ```

##  Setup

Consult requires some database tables for conversations, messages, and associated data.

Run `mix consult.show_expected_structure` to see an example migration that would add the tables it needs, then either create and run an identical migration, or write your own migration to make your schema match the one shown.
