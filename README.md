# Events

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

### Notes
  - `mix phx.gen.html Name Name name db_fields` to create a new resource
  - after above, need to edit migration file in `priv/repo/migrations/...`
  - then add resource to router
  - from what I understand, running a db migration syncs the db and app data. Create with
    
      mix ecto.gen.migration [migration_name]

  - that will generate some repo files that you specify your tables in. To sync and actually create the table,
    
      mix ecto.migrate

