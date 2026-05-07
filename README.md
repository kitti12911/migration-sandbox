# migration-sandbox

Shared PostgreSQL and SQL Server migration workspace for homelab services.

This repository is the source of truth for database migrations that must be
coordinated across services sharing the same database.

## Layout

```text
migration/
├── postgres/
│   └── examples/
│       ├── migrations/  # PostgreSQL schema migrations
│       └── seeds/       # PostgreSQL seed migrations
└── mssql/
    └── examples/
        ├── migrations/  # SQL Server schema migrations
        └── seeds/       # SQL Server seed migrations
```

Migration files use [Goose](https://github.com/pressly/goose) SQL directives.

## Setup

Install Goose:

```sh
go install github.com/pressly/goose/v3/cmd/goose@v3.27.1
```

Install SQLFluff on macOS:

```sh
brew install pipx
pipx install sqlfluff==4.1.0
```

Install SQLFluff on Linux:

```sh
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install sqlfluff==4.1.0
```

Create local environment config:

```sh
cp .env.example .env
```

Update `.env` for the target database. `.env` is ignored by Git. Keep one
target uncommented, comment the others, then run the migration command.

`GOOSE_TABLE` controls where schema migration versions are recorded.
`GOOSE_SEED_TABLE` does the same for seed migration versions. Use a
schema-qualified table name when you want the Goose version tables in a
dedicated schema:

```env
GOOSE_MIGRATION_DIR=migration/postgres/examples/migrations
GOOSE_SEED_DIR=migration/postgres/examples/seeds
GOOSE_TABLE=migration.goose_db_version
GOOSE_SEED_TABLE=migration.goose_seed_version
```

Schema migration commands use Goose's `GOOSE_MIGRATION_DIR` directly. Seed
commands temporarily point `GOOSE_MIGRATION_DIR` at `GOOSE_SEED_DIR`, so seeds
can keep their own version table.

## Commands

| Command               | Description                                     |
| --------------------- | ----------------------------------------------- |
| `make fmt`            | Format SQL migration and seed files             |
| `make pretty`         | Format Markdown, YAML, JSON, and JSONC          |
| `make format`         | Run SQL and document/config formatting          |
| `make lint`           | Run SQL and Markdown linting                    |
| `make lint-sql`       | Lint SQL migration and seed files with SQLFluff |
| `make markdownlint`   | Lint Markdown files                             |
| `make lint-postgres`  | Lint PostgreSQL SQL files                       |
| `make lint-mssql`     | Lint SQL Server SQL files                       |
| `make validate`       | Validate Goose migration and seed files         |
| `make migrate-up`     | Apply pending schema migrations                 |
| `make migrate-down`   | Roll back the latest schema migration           |
| `make migrate-status` | Show schema migration status                    |
| `make migrate-create` | Create a new schema migration; requires `NAME`  |
| `make seed-up`        | Apply pending seed migrations                   |
| `make seed-down`      | Roll back the latest seed migration             |
| `make seed-status`    | Show seed migration status                      |
| `make seed-create`    | Create a new seed migration; requires `NAME`    |

## Examples

Create a schema migration:

```sh
make migrate-create NAME=create_users_table
```

Create a seed migration:

```sh
make seed-create NAME=seed_users
```

Validate migration files:

```sh
make validate
```

Lint SQL:

```sh
make lint
```

Apply schema migrations:

```sh
make migrate-up
```

Apply seed migrations:

```sh
make seed-up
```

## Migration Rules

- Do not edit an already-applied migration.
- Fix migration mistakes with a new migration.
- Prefer forward-compatible changes.
- Use expand-contract changes for breaking schema updates.
- Keep seed migrations idempotent where possible.
