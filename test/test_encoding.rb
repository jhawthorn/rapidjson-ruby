# frozen_string_literal: true

require "test_helper"

class TestEncoding < Minitest::Test
  def test_encoding
    assert_equal Encoding::UTF_8, encode([]).encoding
  end

  def test_encode_NaN_and_Infinity
    error = assert_raises RapidJSON::EncodeError do
      encode(Float::NAN)
    end
    assert_match "Float::NAN is not allowed in JSON", error.message

    error = assert_raises RapidJSON::EncodeError do
      encode(Float::INFINITY)
    end
    assert_match "Float::INFINITY is not allowed in JSON", error.message

    error = assert_raises RapidJSON::EncodeError do
      encode(-Float::INFINITY)
    end
    assert_match "Float::INFINITY is not allowed in JSON", error.message
  end

  def test_character_encodings
    ["UTF-8", "Shift_JIS", "Windows-31J"].each do |encoding|
      s = "二".encode(encoding)
      assert_equal %q{"二"}, encode(s)
      assert_equal %q{{"二":"二"}}, encode(s => s)
      assert_equal %q{{"二":"二"}}, encode(s.to_sym => s.to_sym)
    end
  end

  private

  def encode(object)
    RapidJSON.dump(object)
  end
end
