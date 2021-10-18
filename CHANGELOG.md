# ulid-rails CHANGELOG

## 0.5

- Ensure ULID order respects timestamp order to millisecond precision.

- Validation of ULID format when setting value. A wrong format value will trigger a `ULID::Rails::ArgumentError`.

## 0.3

- Support PostgresQL

## 0.2

### Breaking Changes

- `primary_key` option's default has been changed to `false`. Now you need to specify `primary_key: true` for primary keys: `ulid :id, primary_key: true`

### New Features

- Added `auto_generate` option

### Bug Fixes

- Auto-generate was on for foreign keys
- Encoded ULID was not 0-padded #1
