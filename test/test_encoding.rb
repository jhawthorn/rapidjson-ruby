# frozen_string_literal: true

require "test_helper"

class TestEncoderCompatibility < Minitest::Test
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

  private

  def encode(object)
    RapidJSON.dump(object)
  end
end
