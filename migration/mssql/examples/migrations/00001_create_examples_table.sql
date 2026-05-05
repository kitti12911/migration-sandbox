-- +goose Up
-- +goose StatementBegin
IF OBJECT_ID(N'dbo.examples', N'U') IS NULL
    CREATE TABLE dbo.examples (
        [id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
        [example_name] NVARCHAR(255) NOT NULL,
        [created_at] DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME()
    );
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS dbo.examples;
-- +goose StatementEnd
