$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'irb'
require "ulid/rails"

require "minitest/autorun"

db_sets = {
  "sqlite3" => {
    adapter: 'sqlite3',
    name: ':memory:'
  },
  "mysql56" => {
    host: 'mysql56',
    adapter: 'mysql2',
    username: 'root',
    password: 'password',
    name: 'test'
  },
  "mysql57" => {
    host: 'mysql57',
    adapter: 'mysql2',
    username: 'root',
    password: 'password',
    name: 'test'
  },
  "mysql80" => {
    host: 'mysql80',
    adapter: 'mysql2',
    username: 'root',
    password: 'password',
    name: 'test'
  },
  "pg12" => {
    host: 'pg12',
    adapter: 'postgresql',
    username: 'postgres',
    name: 'test'
  },
}
db = db_sets[ENV["DB"]] || db_sets['sqlite3']

if db[:adapter] != 'sqlite3'
  ActiveRecord::Base.establish_connection(
    host: db[:host],
    adapter: db[:adapter],
    username: db[:username],
    password: db[:password],
  #  database: db[:name]
  )
  
  ActiveRecord::Base.connection.drop_database(db[:name]) rescue nil
  ActiveRecord::Base.connection.create_database(db[:name])
  
  ActiveRecord::Base.connection.disconnect!
end

ActiveRecord::Base.establish_connection(
  host: db[:host],
  adapter: db[:adapter],
  username: db[:username],
  password: db[:password],
  database: db[:name]
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table(:users, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
  end

  create_table(:books, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
    t.binary :user_id, limit: 16
  end

  create_table(:user_articles, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
    t.binary :user_id, limit: 16
    t.binary :article_id, limit: 16
  end

  create_table(:articles, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
  end
end

class User < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true

  has_many :books
  has_many :user_articles
  has_many :articles, through: :user_articles
end

class Book < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true
  ulid :user_id

  belongs_to :user
end

class UserArticle < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true
  ulid :user_id
  ulid :article_id

  belongs_to :user
  belongs_to :article
end

class Article < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true
end