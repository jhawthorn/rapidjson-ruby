# frozen_string_literal: true

require "test_helper"

# Tests copied from https://github.com/jhawthorn/json_escape
# based on tests originally from Active Support

module JsonEscapeTestCases
  JSON_ESCAPE_TEST_CASES = [
    ["1", "1"],
    ["null", "null"],
    ['"&"', '"\u0026"'],
    ['"</script>"', '"\u003c/script\u003e"'],
    ['["</script>"]', '["\u003c/script\u003e"]'],
    ['{"name":"</script>"}', '{"name":"\u003c/script\u003e"}'],
    [%({"name":"d\u2028h\u2029h"}), '{"name":"d\u2028h\u2029h"}']
  ]

  def test_json_escape
    JSON_ESCAPE_TEST_CASES.each do |(raw, expected)|
      assert_equal expected, json_escape(raw)
    end
  end

  def test_json_escape_does_not_alter_json_string_meaning
    JSON_ESCAPE_TEST_CASES.each do |(raw, _)|
      expected = RapidJSON.parse(raw)
      if expected.nil?
        assert_nil RapidJSON.parse(json_escape(raw))
      else
        assert_equal expected, RapidJSON.parse(json_escape(raw))
      end
    end
  end

  def test_json_escape_is_idempotent
    JSON_ESCAPE_TEST_CASES.each do |(raw, _)|
      assert_equal json_escape(raw), json_escape(json_escape(raw))
    end
  end

  def test_long_strings
    [1, 2, 255, 256, 2**8, 2**16].each do |size|
      str = "\"#{?& * size}\""
      escaped = json_escape(str)
      assert_equal size * 6 + 2, escaped.size
    end
  end

  def test_incompatible_encodings
    JSON_ESCAPE_TEST_CASES.each do |(raw, _)|
      ex = assert_raises Encoding::CompatibilityError do
        json_escape(raw.b)
      end
      assert_equal "input string must be UTF-8 or ASCII", ex.message
    end
  end
end

class TestJsonEscape < Minitest::Test
  include JsonEscapeTestCases
  def json_escape(str)
    RapidJSON.json_escape(str)
  end
end
