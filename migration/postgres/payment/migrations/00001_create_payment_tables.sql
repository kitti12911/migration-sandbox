-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS payment_inbox (
    msg_id TEXT PRIMARY KEY,
    saga_id UUID NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY,
    idempotency_key TEXT NOT NULL,
    saga_id UUID NOT NULL,
    account_id TEXT NOT NULL,
    amount BIGINT NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_payments_idempotency_key UNIQUE (idempotency_key)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS payment_outbox (
    id UUID PRIMARY KEY,
    topic TEXT NOT NULL,
    msg_id TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    sent_at TIMESTAMPTZ,
    CONSTRAINT uq_payment_outbox_msg_id UNIQUE (msg_id)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS ix_payment_outbox_status_created_at
ON payment_outbox (status, created_at);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS payment_outbox;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS payments;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS payment_inbox;
-- +goose StatementEnd
