# ULID::Rails

[![CI tests status](https://github.com/k2nr/ulid-rails/actions/workflows/test.yml/badge.svg?branch%3Amaster)](https://github.com/k2nr/ulid-rails/actions/workflows/test.yml?query=branch%3Amaster) [![CI linting status](https://github.com/k2nr/ulid-rails/actions/workflows/lint.yml/badge.svg?branch%3Amaster)](https://github.com/k2nr/ulid-rails/actions/workflows/lint.yml?query=branch%3Amaster)

This gem makes it possible to use [ULID](https://github.com/ulid/spec) for DB in a Ruby on Rails app.

## Installation

```ruby
gem 'ulid-rails'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install ulid-rails
```

## Usage

First, load up the gem with `require 'ulid/rails'`.

### Migrations

Specify `id: false` to `create_table` and add `id` column as 16-byte binary type.

```ruby
  def change
    create_table :users, id: false do |t|
      t.binary :id, limit: 16, primary_key: true
      # ...
    end
  end
```

**MySQL note:** You can also declare the `id` column as `t.column :id, 'binary(16)'` when using MySQL, given that the syntax in the example will generate a SQL that makes the id as `VARBINARY(16)` instead of `BINARY(16)`.

### Model Changes

Just add the below lines to your models.

```ruby
class MyModel < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true # The first argument is the ULID column name
end
```

### Extract timestamp

Since ULID includes milli seconds precision timestamp, you don't need to store `created_at`.
`ulid-rails` provides a helper method that defines timestamp method which extract timestamp from ULID column.

```ruby
class MyModel < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true # The first argument is the ULID column name

  # defines `created_at` method which extract timestamp value from id column.
  # This way you don't need physical `created_at` column.
  ulid_extract_timestamp :id, :created_at
end
```

### `created_at` virtual column

**MySQL 5.7 and higher Only (for now)**

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

If `auto_generate` is `true`, ULID is auto-generated before create by default.
If not specified, the default is `false`.

```
class Model < ApplicationRecord
  ulid :id, auto_generate: true #  auto-generate enabled
  ulid :foreign_key # auto-generate disabled
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

### Many to many associations

Please note that this library doesn't work properly with `has_and_belongs_to_many` associations.

Our recommendation is to be explicit and instead use the `has_many, through: join_class` association.
Notice that for it to work properly you must specify the `has_many` to the join class in the main classes of the association,
and your join class must have `belongs_to` main classes defined as shown in the example below:

```ruby
  class User < ActiveRecord::Base
    include ULID::Rails
    ulid :id, auto_generate: true

    has_many :user_articles
    has_many :articles, through: :user_articles
  end

  class UserArticle < ActiveRecord::Base
    include ULID::Rails
    ulid :id, auto_generate: true
    ulid :user_id
    ulid :article_id

    belongs_to :user
    belongs_to :article
  end

  class Article < ActiveRecord::Base
    include ULID::Rails
    ulid :id, auto_generate: true

    has_many :user_articles
  end
```

## Development

### Run tests

Just run the below command to test with all supported DB engines.

```
$ docker compose run test
```

Or run with a specific ActiveRecord version

```
$ docker compose run -e AR_VERSION=6.1 test
```

Or run tests locally, without docker compose

```
$ AR_VERSION=6.1 bundle update && AR_VERSION=6.1 bundle exec rake test
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
