# frozen_string_literal: true

require "test_helper"
require "json"

class TestEncoderCompatibility < Minitest::Test
  def test_encode_array
    assert_compat []
    assert_compat [1,2,3]
    assert_compat [1,2,3,4]
    assert_compat [1.0]
  end

  def test_encode_fixnum
    assert_compat -5
    assert_compat -1
    assert_compat 0
    assert_compat 5
    assert_compat 123
  end

  def test_encode_bignum
    assert_compat 2**63
    assert_compat 2**63 + 1
    assert_compat 2**64 - 1
  end

  def test_encore_arbitrary_size_num
    assert_compat 2**128
  end

  def test_encode_fixnum_exponents
    tests = []
    0.upto(65) do |exponent|
      pow = 2 ** exponent
      tests.concat ((-pow-2)...(-pow+2)).to_a
      tests.concat ((pow-2)...(pow+2)).to_a
    end
    tests.uniq!

    tests.each do |n|
      assert_compat n
    end
  end

  def test_encode_float
    assert_compat 0.0
    assert_compat -0.0
    assert_compat 155.0
  end

  def test_encode_hash
    assert_compat({})
    assert_compat({ "foo" => "bar" })
  end

  def test_encode_hash_nonstring_keys
    assert_compat({1 => 2})

    assert_compat({{1 => 2} => 3})
    assert_compat({["foo"] => "bar"})
    assert_compat({Object.new => 2})

    assert_compat(Object.new => nil)
    assert_compat(12 => nil)
    assert_compat(Integer => nil)
    assert_compat(Time.at(42).utc => nil)
  end

  def test_encode_string
    assert_compat("")
    assert_compat("1")
    assert_compat("foo")
    assert_compat("abcdefghijklmnopqrstuvwxyz")
  end

  def test_encode_symbol
    assert_compat(:foo)
    assert_compat(:bar)
    assert_compat("dynamic symbol".to_sym)
  end

  def test_encode_object
    assert_compat(Object.new)
  end

  def test_to_json
    klass = Class.new do
      def to_json(_state = nil)
        '{ "amazing":"custom json" }'
      end
    end

    assert_compat(klass.new)
  end

  def test_to_s
    klass = Class.new do
      def to_s
        "amazing object!"
      end
    end

    assert_compat(klass.new)
  end

  def test_encode_true
    assert_compat(true)
  end

  def test_encode_false
    assert_compat(false)
  end

  def test_encode_nil
    assert_compat(nil)
  end

  def test_generate_NaN_and_Infinity
    [JSON, RapidJSON::JSONGem].each do |coder|
      assert_raises coder::GeneratorError do
        coder.generate(Float::NAN)
      end

      assert_raises coder::GeneratorError do
        coder.generate(Float::INFINITY)
      end

      assert_raises coder::GeneratorError do
        coder.generate(-Float::INFINITY)
      end
    end
  end

  def test_dump_NaN_and_Infinity
    assert_dump_equal [Float::NAN, Float::INFINITY, -Float::INFINITY]
  end

  module ToJsonWithActiveSupportEncoder
    # Taken from Rails. It checks the `to_json` argument to see if it's
    # being called by stdlib.
    def to_json(options = nil)
      if options.is_a?(::JSON::State)
        # Called from JSON.{generate,dump}, forward it to JSON gem's to_json
        super(options)
      else
        # to_json is being invoked directly, use ActiveSupport's encoder
        raise "Calling ActiveSupport::JSON.encode(self, options)"
      end
    end
  end

  class CustomTime < Time
    include ToJsonWithActiveSupportEncoder
  end

  def test_encode_active_support_as_json
    assert_compat CustomTime.new
  end

  private

  def assert_compat(object)
    assert_dump_equal(object)
    assert_generate_equal(object)
  end

  def assert_dump_equal(object, *args)
    assert_equal ::JSON.dump(object, *args), RapidJSON::JSONGem.dump(object, *args)
  end

  def assert_generate_equal(object, *args)
    assert_equal ::JSON.generate(object, *args), RapidJSON::JSONGem.generate(object, *args)
  end
end
