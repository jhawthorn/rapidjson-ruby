# frozen_string_literal: true

require "test_helper"

# jsonchecker suite. originally from
# http://json.org/JSON_checker/
class TestJsonchecker < Minitest::Test
  Dir["#{DATA_DIR}/jsonchecker/*.json"].each do |filename|
    name = File.basename(filename, ".json").gsub(/_EXCLUDE\z/, "")
    exclude = filename.end_with?("_EXCLUDE.json")

    define_method(:"test_#{name}") do
      original_json = File.read(filename)
      if name.start_with?("fail") && !exclude
        refute RapidJSON.valid_json?(original_json)
        ex = assert_raises RapidJSON::ParseError do
          RapidJSON.parse(original_json)
        end
        re = /JSON parse error: .* \(\d+\)\z/
        assert_match re, ex.message
      else
        assert RapidJSON.valid_json?(original_json)
        assert RapidJSON.parse(original_json)
      end
    end
  end
end
