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

If you use MySQL, specify `id: false` to `create_table` and add `id` column as 16-byte binary type.

```ruby
  def change
    create_table :users, id: false do |t|
      t.binary :id, limit: 16, primary_key: true # MySQL
      # ...
    end
  end
```

If you use PostgreSQL, just specify `id: :uuid` to `create_table`

```ruby
  def change
    create_table :users, id: :uuid do |t|
      # ...
    end
  end
```


### Model Changes

Just add the below lines to your models.

```ruby
class MyModel < ApplicationRecord
  include ULID::Rails
  ulid :id # The argument is the primary key column name
end
```

### `created_at` virtual column

**MySQL Only (for now)**

Since ULID includes milli seconds precision timestamp, you don't need to store `created_at`. You can instead create a virtual column that extracts the timestamp from the ULID column.

Defining the virtual `created_at` is kind of comlicated so this gem provides a helper method for it.

```ruby
    create_table :users, id: false do |t|
      t.binary :id, limit: 16, primary_key: true
      t.datetime :updated_at
      t.virtual_ulid_timestamp :created_at, :id
    end
```

`virtual_ulid_timestamp` takes two arguments, the first one is the name of the column name (typically, `created_at`) and the second one is the ULID column that creation timestamp is extracted from.

## FAQ

### Foreign Keys

You need to specicfy `type` option

```ruby
    # MySQL
    create_table :admin_usees do |t|
      t.references :admin_user, foreign_key: true, type: "BINARY(16)"
    end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
