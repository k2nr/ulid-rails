require "test_helper"

class ULID::Rails::TypeTest < Minitest::Test
  def setup
    @ulid = "01ARZ3NDEKTSV4RRFFQ69G5FAV"
  end

  def type
    case database_adapter
    when "mysql2"
      ULID::Rails::Type.new
    when "sqlite3"
      ULID::Rails::SqliteType.new
    when "postgresql"
      ULID::Rails::PostgresqlType.new
    else
      raise "Unknown #{database_adapter}"
    end
  end

  def test_serialize_to_s
    expected_string = {
      "mysql2" => "01ARZ3NDEKTSV4RRFFQ69G5FAV",
      "sqlite3" => "01563e3ab5d3d6764c61efb99302bd5b",
      "postgresql" => "\x01V>:\xB5\xD3\xD6vLa\xEF\xB9\x93\x02\xBD[".b
    }.fetch(database_adapter)

    assert_equal expected_string, type.serialize(@ulid).to_s
  end

  def test_serialize_hex
    expected_hex = {
      "mysql2" => "01563e3ab5d3d6764c61efb99302bd5b",
      "sqlite3" => "01563e3ab5d3d6764c61efb99302bd5b",
      "postgresql" => "\x01V>:\xB5\xD3\xD6vLa\xEF\xB9\x93\x02\xBD[".b
    }.fetch(database_adapter)

    assert_equal expected_hex, type.serialize(@ulid).hex
  end

  def test_deserialize
    serialized_value = {
      "mysql2" => "\x01V>:\xB5\xD3\xD6vLa\xEF\xB9\x93\x02\xBD[".b,
      "sqlite3" => "01563e3ab5d3d6764c61efb99302bd5b".b,
      "postgresql" => "\\x01563e3ab5d3d6764c61efb99302bd5b".b
    }.fetch(database_adapter)

    assert_equal @ulid, type.deserialize(serialized_value)
  end
end

class ULID::RailsTest < Minitest::Test
  def setup
    model_classes.each(&:delete_all)
  end

  def test_stores_the_ulid_as_binary_value_in_the_database
    user = User.create!(id: "01ARZ3NDEKTSV4RRFFQ69G5FAV")

    raw_id = user.read_attribute_before_type_cast(:id).hex
    expected_raw_id = {
      "mysql2" => "01563e3ab5d3d6764c61efb99302bd5b",
      "sqlite3" => "01563e3ab5d3d6764c61efb99302bd5b",
      "postgresql" => "\x01V>:\xB5\xD3\xD6vLa\xEF\xB9\x93\x02\xBD[".b
    }.fetch(database_adapter)

    assert_equal expected_raw_id, raw_id

    binary_stored_id = User.last.read_attribute_before_type_cast(:id)
    expected_binary_stored_id = {
      "mysql2" => "\x01V>:\xB5\xD3\xD6vLa\xEF\xB9\x93\x02\xBD[".b,
      "sqlite3" => "01563e3ab5d3d6764c61efb99302bd5b".b,
      "postgresql" => "\\x01563e3ab5d3d6764c61efb99302bd5b".b
    }.fetch(database_adapter)

    assert_equal expected_binary_stored_id, binary_stored_id
  end

  def test_deserializes_the_value_back_to_an_ulid
    user = User.create!(id: "01ARZ3NDEKTSV4RRFFQ69G5FAV")
    user.reload

    assert_equal "01ARZ3NDEKTSV4RRFFQ69G5FAV", user.id
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

  def test_loading_associations_with_eager_load
    user = User.create!
    user.books.create!

    result = User.eager_load(:books).to_a

    assert_equal [user], result
  end

  def test_loading_associations_with_eager_load_with_limit
    user = User.create!
    user.books.create!

    result = User.eager_load(:books).limit(1).to_a

    assert_equal [user], result
  end

  def test_loading_associations_with_includes
    user = User.create!
    user.books.create!

    result = User.includes(:books).to_a

    assert_equal [user], result
  end

  def test_loading_associations_with_joins
    user = User.create!
    user.books.create!

    result = User.joins(:books).to_a

    assert_equal [user], result
  end

  def test_loading_associations_with_left_outer_joins
    user = User.create!
    user.books.create!

    result = User.left_outer_joins(:books).to_a

    assert_equal [user], result
  end

  def test_loading_associations_with_preload
    user = User.create!
    user.books.create!

    result = User.preload(:books).to_a

    assert_equal [user], result
  end

  def test_type_casting
    user = User.create!(id: "01ARZ3NDEKTSV4RRFFQ69G5FAV")

    user.reload

    raw_id = user.read_attribute_before_type_cast(:id)
    expected_raw_id = {
      "mysql2" => "\x01V>:\xB5\xD3\xD6vLa\xEF\xB9\x93\x02\xBD[".b,
      "sqlite3" => "01563e3ab5d3d6764c61efb99302bd5b".b,
      "postgresql" => "\\x01563e3ab5d3d6764c61efb99302bd5b".b
    }.fetch(database_adapter)

    assert_equal expected_raw_id, raw_id
    assert_equal "01ARZ3NDEKTSV4RRFFQ69G5FAV", user.id
  end

  def test_find_with_where_and_singular_string_arg
    user = User.create!

    assert_equal [user], User.where(id: user.id)
  end

  def test_find_with_where_and_singular_integer_arg
    User.create!

    assert_empty User.where(id: 42)
  end

  def test_find_with_where_and_singular_weird_arg
    User.create!

    assert_empty User.where(id: Date.new)
  end

  def test_find_with_where_and_ulid_array
    user_1 = User.create!
    user_2 = User.create!

    assert_equal [user_1, user_2].sort, User.where(id: [user_1.id, user_2.id]).sort
  end

  def test_find_with_where_and_string_array
    user = User.create!

    assert_equal [user], User.where(id: [user.id, "this-is-not-a-ulid"])
  end

  def test_find_with_where_and_integer_array
    User.create!

    assert_empty User.where(id: [42, 100])
  end

  def test_find_with_where_and_mixed_type_array
    user = User.create!

    assert_equal [user], User.where(id: [42, user.id, Time.now])
  end

  private

  def model_classes
    ActiveRecord::Base.descendants - [ActiveRecord::InternalMetadata, ActiveRecord::SchemaMigration]
  end
end
