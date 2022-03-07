# frozen_string_literal: true

require "test_helper"

# test round trips from nativejson-benchmark
# https://github.com/miloyip/nativejson-benchmark
class TestRoundtrip < Minitest::Test
  Dir["#{DATA_DIR}/roundtrip/*.json"].each do |filename|
    name = File.basename(filename, ".json")
    define_method(:"test_#{name}") do
      original_json = File.read(filename)
      parsed = RapidJSON.parse(original_json)
      encoded = RapidJSON.encode(parsed)
      assert_equal original_json, encoded
    end
  end
end
