# frozen_string_literal: true

require "test_helper"

class TestEncoder < Minitest::Test
  def encode obj
    RapidJSON.encode(obj)
  end

  def test_encode_array
    assert_equal "[]", encode([])
    assert_equal "[1,2,3]", encode([1,2,3])
    assert_equal "[1,2,3,4]", encode([1,2,3,4])
    assert_equal "[1.0]", encode([1.0])
  end

  def test_encode_fixnum
    assert_equal "-5", encode(-5)
    assert_equal "-1", encode(-1)
    assert_equal "0", encode(0)
    assert_equal "5", encode(5)
    assert_equal "123", encode(123)
  end

  def test_encode_bignum
    assert_equal "9223372036854775808", encode(2**63)
    assert_equal "9223372036854775809", encode(2**63 + 1)
    assert_equal "18446744073709551615", encode(2**64 - 1)
  end

  def test_encode_fixnum_exponents
    tests = []
    0.upto(65) do |exponent|
      pow = 2 ** exponent
      tests.concat ((-pow-2)...(-pow+2)).to_a
      tests.concat ((pow-2)...(pow+2)).to_a
    end
    tests.uniq!

    # Should we test that these get represented as floats?
    tests.reject! do |n|
      n > RbConfig::LIMITS["UINT64_MAX"] ||
        n < RbConfig::LIMITS["INT64_MIN"]
    end

    tests.each do |n|
      assert_equal n.to_s, encode(n)
    end
  end

  def test_encode_float
    assert_equal "0.0", encode(0.0)
    assert_equal "-0.0", encode(-0.0)
    assert_equal "155.0", encode(155.0)
  end

  def test_encode_hash
    assert_equal '{}', encode({})
    assert_equal '{"foo":"bar"}', encode({ "foo" => "bar" })
  end

  def test_encode_string
    assert_equal '""', encode("")
    assert_equal '"1"', encode("1")
    assert_equal '"foo"', encode("foo")
    assert_equal '"abcdefghijklmnopqrstuvwxyz"', encode("abcdefghijklmnopqrstuvwxyz")
  end

  def test_encode_symbol
    assert_equal '"foo"', encode(:foo)
    assert_equal '"bar"', encode(:bar)
    assert_equal '"dynamic symbol"', encode("dynamic symbol".to_sym)
  end

  def test_encode_object
    ex = assert_raises RapidJSON::EncodeError do
      encode(Object.new)
    end
    assert_match(/can't encode type/, ex.message)
  end

  def test_encode_true
    assert_equal "true", encode(true)
  end

  def test_encode_false
    assert_equal "false", encode(false)
  end

  def test_encode_nil
    assert_equal "null", encode(nil)
  end
end
