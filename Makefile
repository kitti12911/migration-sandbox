# ____________________ Tool Commands ____________________
GOOSE ?= goose
SQLFLUFF ?= $(or $(shell command -v sqlfluff 2>/dev/null),$(HOME)/.local/bin/sqlfluff)

# ____________________ Migration Config ____________________
ifneq (,$(wildcard .env))
include .env
export
endif

GOOSE_DRIVER ?= postgres
GOOSE_DBSTRING ?= postgres://example_user:example_password@postgres.lan:5432/example?sslmode=disable
GOOSE_MIGRATION_DIR ?= migration/migrations
GOOSE_SEED_DIR ?= migration/seeds
GOOSE_TABLE ?= goose_db_version
GOOSE_SEED_TABLE ?= goose_seed_version
POSTGRES_SQL_FILES := $(shell find migration/postgres -name '*.sql' 2>/dev/null)
MSSQL_SQL_FILES := $(shell find migration/mssql -name '*.sql' 2>/dev/null)
MIGRATION_DIRS := $(shell find migration -type d -name migrations 2>/dev/null)
SEED_DIRS := $(shell find migration -type d -name seeds 2>/dev/null)

# ____________________ Format Command ____________________
fmt:
	$(MAKE) fmt-postgres
	$(MAKE) fmt-mssql

fmt-postgres:
ifneq ($(strip $(POSTGRES_SQL_FILES)),)
	$(SQLFLUFF) fix --dialect postgres $(POSTGRES_SQL_FILES)
else
	@echo "no PostgreSQL SQL files to format"
endif

fmt-mssql:
ifneq ($(strip $(MSSQL_SQL_FILES)),)
	$(SQLFLUFF) fix --dialect tsql $(MSSQL_SQL_FILES)
else
	@echo "no SQL Server SQL files to format"
endif

format: fmt

# ____________________ Lint Command ____________________
lint:
	$(MAKE) lint-postgres
	$(MAKE) lint-mssql

lint-postgres:
ifneq ($(strip $(POSTGRES_SQL_FILES)),)
	$(SQLFLUFF) lint --dialect postgres $(POSTGRES_SQL_FILES)
else
	@echo "no PostgreSQL SQL files to lint"
endif

lint-mssql:
ifneq ($(strip $(MSSQL_SQL_FILES)),)
	$(SQLFLUFF) lint --dialect tsql $(MSSQL_SQL_FILES)
else
	@echo "no SQL Server SQL files to lint"
endif

# ____________________ Migration Validation Command ____________________
validate: validate-migrations validate-seeds

validate-migrations:
ifneq ($(strip $(MIGRATION_DIRS)),)
	@for dir in $(MIGRATION_DIRS); do \
		if find "$$dir" -maxdepth 1 -name '*.sql' | grep -q .; then \
			echo "$(GOOSE) -dir $$dir validate"; \
			$(GOOSE) -dir "$$dir" validate; \
		else \
			echo "no schema migrations to validate in $$dir"; \
		fi; \
	done
else
	@echo "no schema migrations to validate"
endif

validate-seeds:
ifneq ($(strip $(SEED_DIRS)),)
	@for dir in $(SEED_DIRS); do \
		if find "$$dir" -maxdepth 1 -name '*.sql' | grep -q .; then \
			echo "$(GOOSE) -dir $$dir validate"; \
			$(GOOSE) -dir "$$dir" validate; \
		else \
			echo "no seed migrations to validate in $$dir"; \
		fi; \
	done
else
	@echo "no seed migrations to validate"
endif

# ____________________ Migration Command ____________________
migrate-up:
	$(GOOSE) -table $(GOOSE_TABLE) up

migrate-down:
	$(GOOSE) -table $(GOOSE_TABLE) down

migrate-status:
	$(GOOSE) -table $(GOOSE_TABLE) status

migrate-create:
ifndef NAME
	$(error NAME is required. Usage: make migrate-create NAME=create_examples_table)
endif
	$(GOOSE) -s create $(NAME) sql

seed-up:
	GOOSE_MIGRATION_DIR=$(GOOSE_SEED_DIR) $(GOOSE) -table $(GOOSE_SEED_TABLE) up

seed-down:
	GOOSE_MIGRATION_DIR=$(GOOSE_SEED_DIR) $(GOOSE) -table $(GOOSE_SEED_TABLE) down

seed-status:
	GOOSE_MIGRATION_DIR=$(GOOSE_SEED_DIR) $(GOOSE) -table $(GOOSE_SEED_TABLE) status

seed-create:
ifndef NAME
	$(error NAME is required. Usage: make seed-create NAME=create_examples_seed)
endif
	GOOSE_MIGRATION_DIR=$(GOOSE_SEED_DIR) $(GOOSE) -s create $(NAME) sql
