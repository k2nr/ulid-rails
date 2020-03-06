require "test_helper"

class ULID::RailsTest < Minitest::Test
  def test_primary_key
    user = User.create!
    assert user.id.is_a? String
    assert user.id.length == 26

    id = user.id
    user.reload
    assert id == user.id
  end

  def test_has_many
    user = User.create!
    book = user.books.create!

    assert book.user_id == user.id

    id = book.id
    book.reload
    assert id == book.id
  end

  def test_auto_generate_non_primary_key
    widget = WidgetWithAutoGeneratedUlid.create!
    assert widget.ulid
  end

  def test_has_many_through
    # Doesn't work until https://github.com/rails/rails/issues/35839 is released
    # Working correctly if has_many in many-to-many model is defined
    user = User.create!
    article = user.articles.create!
    user.reload

    assert user.articles.count == 1
    assert user.articles[0] == article
  end

  # def test_has_many_through_from_has_many_through
  #   # Doesn't work for MySQL and Postgresql
  #   # Cause:
  #   # ULID::Rails::Type#serialize and 
  #   # ULID::Rails::Type#deserialize is not called
  #   # Instead ActiveModel::Type::Binary#serialize and
  #   # ActiveModel::Type::Binary#deserialize is called
  #   user = User.create!
  #   article = user.articles.create!
  #   comment = article.comments.create! # working correctly
  #   user.reload

  #   assert user.articles.count == 1
  #   assert user.comments == [comment] # not working
  # end
end
