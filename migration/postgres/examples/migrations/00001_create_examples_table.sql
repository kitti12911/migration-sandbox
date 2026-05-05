-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS examples (
    id UUID PRIMARY KEY,
    example_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS examples;
-- +goose StatementEnd
