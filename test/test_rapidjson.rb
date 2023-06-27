# frozen_string_literal: true

require "test_helper"

class TestRapidJSON < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RapidJSON::VERSION
  end

  def test_load
    obj = {"foo" => 123}
    json = %q{{"foo":123}}
    assert_equal obj, RapidJSON.load(json)
    assert_equal obj, RapidJSON.parse(json)
  end

  def test_dump
    obj = {"foo" => 123}
    json = %q{{"foo":123}}
    assert_equal json, RapidJSON.dump(obj)
    assert_equal json, RapidJSON.encode(obj)
  end

  def test_pretty_encode
    obj = {"foo" => 123}
    json = <<~JSON.strip
      {
        "foo": 123
      }
    JSON
    assert_equal json, RapidJSON.pretty_encode(obj)
  end

  def test_valid_json?
    json = %q{{"foo":123}}
    assert RapidJSON.valid_json?(json)
    refute RapidJSON.valid_json?("--")
  end
end
