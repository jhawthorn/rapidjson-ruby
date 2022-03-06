# frozen_string_literal: true

require "test_helper"

class TestRapidjson < Minitest::Test
  def test_encoding
    s = RapidJSON.dump({})
    p s
  end
end
