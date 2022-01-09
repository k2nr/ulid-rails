# ulid-rails CHANGELOG

## 1.0.0

- Drop support for Rails 4.2.

### Breaking Changes

- `primary_key` option has been removed. You need to specify `auto_generate: true` to automatically fill your primary key columns.

## 0.6.0

- Add support for Rails 4.2, 5.0 and 5.1.
- Known Issue: AREL expressions incorrectly serialize ULID values in Rails 4.2 (#27).

## 0.5.0

- Ensure ULID order respects timestamp order to millisecond precision.
- Validation of ULID format when setting value. A wrong format value will trigger a `ULID::Rails::ArgumentError`.

## 0.4.0

- Support old ruby versions
- Fix auto_generate #2

## 0.3.0

- Support PostgresQL

## 0.2.0

### Breaking Changes

- `primary_key` option's default has been changed to `false`. Now you need to specify `primary_key: true` for primary keys: `ulid :id, primary_key: true`

### New Features

- Added `auto_generate` option

### Bug Fixes

- Auto-generate was on for foreign keys
- Encoded ULID was not 0-padded #1
