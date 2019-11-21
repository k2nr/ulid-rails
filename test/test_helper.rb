$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ulid/rails"

require "minitest/autorun"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
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
  ulid :id, primary_key: true, auto_generate: true

  has_many :books
  has_many :user_articles
  has_many :articles, through: :user_articles
end

class Book < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true, auto_generate: true
  ulid :user_id

  belongs_to :user
end

class UserArticle < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true, auto_generate: true
  ulid :user_id
  ulid :article_id

  belongs_to :user
  belongs_to :article
end

class Article < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true, auto_generate: true
end