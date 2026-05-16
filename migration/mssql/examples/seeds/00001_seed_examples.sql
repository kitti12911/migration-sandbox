-- +goose Up
-- +goose StatementBegin
IF
    NOT EXISTS (
        SELECT 1
        FROM dbo.examples
        WHERE [id] = '019ddd16-c6a8-7907-a282-406a324cbec9'
    )
    INSERT INTO dbo.examples ([id], [example_name])
    VALUES ('019ddd16-c6a8-7907-a282-406a324cbec9', 'Example');
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM dbo.examples
WHERE [id] = '019ddd16-c6a8-7907-a282-406a324cbec9';
-- +goose StatementEnd
