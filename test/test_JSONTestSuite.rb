# frozen_string_literal: true

require "test_helper"

# Test suite from "Parsing JSON is a Minefield"
# https://seriot.ch/projects/parsing_json.html
# https://github.com/nst/JSONTestSuite
class TestJsonchecker < Minitest::Test
  Dir["#{DATA_DIR}/JSONTestSuite/test_parsing/*.json"].each do |filename|
    name = File.basename(filename, ".json")

    define_method(:"test_#{name}") do
      original_json = File.read(filename)
      expectation = name[0]

      if original_json.include?(0.chr)
        return skip("FIXME: better null handling")
      end

      if expectation == "n"
        assert_invalid_json(original_json)
      elsif expectation == "y"
        assert_valid_json(original_json)
      elsif expectation == "i"
        assert_optional_support(original_json)
      else
        raise "unrecognized filename: #{filenme}"
      end
    end
  end

  def assert_optional_support(original_json)
    # Whatever it is, just be consistent
    if RapidJSON.valid_json?(original_json)
      assert_valid_json(original_json)
    else
      assert_invalid_json(original_json)
    end
  end

  def assert_valid_json(original_json)
    assert RapidJSON.valid_json?(original_json)
    RapidJSON.parse(original_json)
  end

  def assert_invalid_json(original_json)
    refute RapidJSON.valid_json?(original_json)
    ex = assert_raises RapidJSON::ParseError do
      RapidJSON.parse(original_json)
    end
    #re = /JSON parse error: .* \(\d+\)\z/
    re = /JSON parse error: .*/
    assert_match re, ex.message
  end
end
