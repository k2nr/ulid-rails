module ULID
  module Rails
    RAILS_VERSION = "#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"
    RAILS_4_2 = RAILS_VERSION == "4.2"
  end
end
