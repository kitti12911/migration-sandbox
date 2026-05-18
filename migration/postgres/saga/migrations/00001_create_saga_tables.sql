-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS saga_instances (
    id UUID PRIMARY KEY,
    saga_type TEXT NOT NULL,
    idempotency_key TEXT NOT NULL,
    state TEXT NOT NULL,
    current_step INTEGER NOT NULL DEFAULT 0,
    payload JSONB NOT NULL,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_saga_instances_idempotency_key UNIQUE (saga_type, idempotency_key)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS ix_saga_instances_state_updated_at
ON saga_instances (state, updated_at);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS saga_steps (
    id UUID PRIMARY KEY,
    saga_id UUID NOT NULL REFERENCES saga_instances (id) ON DELETE CASCADE,
    step_index INTEGER NOT NULL,
    step_name TEXT NOT NULL,
    kind TEXT NOT NULL,
    status TEXT NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    request JSONB,
    response JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_saga_steps_step UNIQUE (saga_id, step_index, kind)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS saga_outbox (
    id UUID PRIMARY KEY,
    saga_id UUID NOT NULL REFERENCES saga_instances (id) ON DELETE CASCADE,
    topic TEXT NOT NULL,
    msg_id TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    sent_at TIMESTAMPTZ,
    CONSTRAINT uq_saga_outbox_msg_id UNIQUE (msg_id)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS ix_saga_outbox_status_created_at
ON saga_outbox (status, created_at);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS saga_outbox;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS saga_steps;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS saga_instances;
-- +goose StatementEnd
