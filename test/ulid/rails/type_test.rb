require "test_helper"

class ULID::Rails::Type::DataTest < Minitest::Test
  def test_has_26_valid_characters
    id = "01BX5ZZKBKACTAV9WEVGEMMVRZ"

    assert ULID::Rails::Type::Data.valid_ulid?(id)
  end

  def test_length_less_than_26
    id = "A" * 25

    refute ULID::Rails::Type::Data.valid_ulid?(id)
  end

  def test_length_greater_than_26
    id = "A" * 27

    refute ULID::Rails::Type::Data.valid_ulid?(id)
  end

  # Crockford's Base32 is used as shown. This alphabet excludes
  # the letters I, L, O, and U to avoid confusion and abuse.
  # https://github.com/ulid/spec#encoding
  def test_has_invalid_characters
    invalid_characters = %w[I L O U]

    invalid_characters.each do |char|
      id = char * 26

      refute ULID::Rails::Type::Data.valid_ulid?(id)
    end
  end

  # The first character in a ULID must be 0, 7, or in between.
  # Anything larger than 7, and the id would not fit into 16 bytes.
  def test_does_not_exceed_16_bytes
    valid_first_characters = ("0".."7").to_a

    valid_first_characters.each do |char|
      id = "#{char}#{"A" * 25}"

      assert ULID::Rails::Type::Data.valid_ulid?(id)
    end

    invalid_first_characters = ("8".."9").to_a + ("A".."Z").to_a

    invalid_first_characters.each do |char|
      id = "#{char}#{"A" * 25}"

      refute ULID::Rails::Type::Data.valid_ulid?(id)
    end
  end
end
