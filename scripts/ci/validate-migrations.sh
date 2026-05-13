#!/usr/bin/env sh
set -eu

project_dir="${CI_PROJECT_DIR:-$(pwd)}"
cd "${project_dir}"

GOOSE="${GOOSE:-goose}"

validate_goose_dirs() {
	dir_name="$1"
	label="$2"

	dirs="$(find migration -type d -name "${dir_name}" 2>/dev/null || true)"
	if [ -z "${dirs}" ]; then
		echo "no ${label} to validate"
		return 0
	fi

	for dir in ${dirs}; do
		if find "${dir}" -maxdepth 1 -name '*.sql' | grep -q .; then
			echo "${GOOSE} -dir ${dir} validate"
			"${GOOSE}" -dir "${dir}" validate
		else
			echo "no ${label} to validate in ${dir}"
		fi
	done
}

validate_goose_dirs migrations "schema migrations"
validate_goose_dirs seeds "seed migrations"
