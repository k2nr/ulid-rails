# ULID::Rails

This gem makes it possible to use [ULID](https://github.com/ulid/spec) for DB primary keys in a Ruby on Rails app.


## Installation


```ruby
gem 'ulid-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ulid-rails

## Usage

### Migrations

Specify `id: false` to `create_table` and add `id` column as 16-byte binary type.

```ruby
  def change
    create_table :users, id: false do |t|
      t.binary :id, limit: 16, primary_key: true # MySQL
      # ...
    end
  end
```


### Model Changes

Just add the below lines to your models.

```ruby
class MyModel < ApplicationRecord
  include ULID::Rails
  ulid :id, primary_key: true # The first argument is the ULID column name
end
```

### Extract timestamp

Since ULID includes milli seconds precision timestamp, you don't need to store `created_at`.
`ulid-rails` provides a helper method that defines timestamp method which extract timestamp from ULID column.

```ruby
class MyModel < ApplicationRecord
  include ULID::Rails
  ulid :id, primary_key: true # The first argument is the ULID column name

  # defines `created_at` method which extract timestamp value from id column.
  # This way you don't need physical `created_at` column.
  ulid_extract_timestamp :id, :created_at
end
```

### `created_at` virtual column

**MySQL Only (for now)**

You can define a "virtual column" in MySQL DB that acts same as a physical column.
Defining the virtual `created_at` is kind of comlicated so this gem provides a helper method for it.

A virtual column is useful if you want to add index on the timestamp column or want to execute raw SQL with created_at.

```ruby
create_table :users, id: false do |t|
  t.binary :id, limit: 16, primary_key: true
  t.datetime :updated_at
  t.virtual_ulid_timestamp :created_at, :id
end
```

`virtual_ulid_timestamp` takes two arguments, the first one is the name of the column name (typically, `created_at`) and the second one is the ULID column that creation timestamp is extracted from.

### Auto-generate ULID

If `primary_key` is `true`, ULID is auto-generated before create by default.
You can enable or disable auto-generation with `auto_generate` option.

```
class Model < ApplicationRecord
  ulid :id, primary_key: true # primary key. auto-generate enabled
  ulid :foreign_key # auto-generate disabled
  ulid :ulid, auto_generate: true # non primary, auto-generate enabled
end
```

### Foreign Keys

You need to specicfy `type` option

```ruby
    # MySQL
    create_table :admin_usees do |t|
      t.references :admin_user, foreign_key: true, type: "BINARY(16)"
    end
```

## Development

### Run tests

Just run the below command to test with all supported DB engines.

```
$ docker-compose run test
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
