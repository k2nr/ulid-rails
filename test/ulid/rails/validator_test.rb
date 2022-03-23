require "test_helper"

class ULID::Rails::ValidatorTest < Minitest::Test
  def test_length_less_than_26
    id = "A" * 25

    assert ULID::Rails::Validator.is_valid?(id) == false
  end

  def test_length_greater_than_26
    id = "A" * 27

    assert ULID::Rails::Validator.is_valid?(id) == false
  end

  # Crockford's Base32 is used as shown. This alphabet excludes 
  # the letters I, L, O, and U to avoid confusion and abuse.
  # https://github.com/ulid/spec#encoding
  def test_has_invalid_characters
    invalid_characters = %w(I L O U)

    invalid_characters.each do |char|
      id = char * 26

      assert ULID::Rails::Validator.is_valid?(id) == false
    end
  end

  def test_has_valid_characters_only
    id = "01BX5ZZKBKACTAV9WEVGEMMVRZ"

    assert ULID::Rails::Validator.is_valid?(id) == true
  end
end
