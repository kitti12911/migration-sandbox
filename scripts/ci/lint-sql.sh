#!/usr/bin/env sh
set -eu

project_dir="${CI_PROJECT_DIR:-$(pwd)}"
cd "${project_dir}"

SQLFLUFF="${SQLFLUFF:-$(command -v sqlfluff 2>/dev/null || printf '%s' "${HOME}/.local/bin/sqlfluff")}"

lint_sql_files() {
	dialect="$1"
	sql_dir="$2"
	label="$3"

	sql_files="$(find "${sql_dir}" -name '*.sql' 2>/dev/null || true)"
	if [ -z "${sql_files}" ]; then
		echo "no ${label} SQL files to lint"
		return 0
	fi

	# SQL migration paths are controlled by this repository and do not contain whitespace.
	# shellcheck disable=SC2086
	"${SQLFLUFF}" lint --dialect "${dialect}" ${sql_files}
}

lint_sql_files postgres migration/postgres "PostgreSQL"
lint_sql_files tsql migration/mssql "SQL Server"
