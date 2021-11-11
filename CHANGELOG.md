# ulid-rails CHANGELOG

## Unreleased

- Drop support for Rails 4.2.

## 0.6

 - Add support for Rails 4.2, 5.0 and 5.1.

## 0.5

- Ensure ULID order respects timestamp order to millisecond precision.
- Validation of ULID format when setting value. A wrong format value will trigger a `ULID::Rails::ArgumentError`.

## 0.4

- Support old ruby versions
- Fix auto_generate #2

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
