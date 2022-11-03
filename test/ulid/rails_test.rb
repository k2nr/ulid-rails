require "test_helper"

class ULID::RailsTest < Minitest::Test
  def setup
    model_classes.each(&:delete_all)
  end

  def test_auto_generate_primary_key
    user = User.create!

    assert user.id.is_a? String
    assert_equal 26, user.id.length

    id = user.id
    user.reload

    assert_equal id, user.id
  end

  def test_auto_generate_non_primary_key
    widget = WidgetWithAutoGeneratedUlid.create!

    assert widget.ulid
  end

  def test_has_many
    user = User.create!
    book = user.books.create!

    assert_equal book.user_id, user.id

    id = book.id
    book.reload

    assert_equal id, book.id
  end

  def test_manual_id_generation
    ulid_id = ULID.generate
    user = User.new(id: ulid_id)

    # here testing that cast is not messing with the setter
    assert_equal user.id, ulid_id

    user.save

    assert_equal user.id, ulid_id
  end

  def test_validate_ulid_format
    non_ulid_id = "I am not a ulid"

    assert_raises(ULID::Rails::ArgumentError) { User.new(id: non_ulid_id) }
  end

  def test_saves_when_ulid_foreign_key_is_nil
    book = Book.create(user_id: nil)

    assert_equal book.reload, Book.last
  end

  def test_has_many_through
    user = User.create!
    article = user.articles.create!
    user.reload

    assert_equal 1, user.articles.count
    assert_equal user.articles[0], article
  end

  private

  def model_classes
    ActiveRecord::Base.descendants - [ActiveRecord::InternalMetadata, ActiveRecord::SchemaMigration]
  end
end
