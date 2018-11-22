require "test_helper"

class ULID::RailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ULID::Rails::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
