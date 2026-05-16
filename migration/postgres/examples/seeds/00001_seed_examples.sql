-- +goose Up
-- +goose StatementBegin
INSERT INTO examples (id, example_name)
VALUES ('019ddd16-c6a8-7907-a282-406a324cbec9', 'Example')
ON CONFLICT (id) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM examples
WHERE id = '019ddd16-c6a8-7907-a282-406a324cbec9';
-- +goose StatementEnd
