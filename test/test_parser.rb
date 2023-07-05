# frozen_string_literal: true

require "test_helper"

class TestParser < Minitest::Test
  def parse obj
    RapidJSON.parse(obj)
  end

  def test_parse_array
    assert_equal [], parse("[]")
    assert_equal [1,2,3,4,5], parse("[1,2,3,4,5]")
    assert_equal [[]], parse("[[]]")
  end

  def test_parse_hash
    assert_equal({}, parse("{}"))
    assert_equal({"three" => 3}, parse('{"three":3}'))
    assert_equal({"foo" => "bar"}, parse('{"foo":"bar"}'))
    assert_equal({"foo" => { "bar" => "baz"}}, parse('{"foo":{"bar":"baz"}}'))
  end

  def test_parse_fixnum
    assert_equal 1, parse("1")
    assert_equal(-1, parse("-1"))
    assert_equal 1000, parse("1000")

    assert_equal 4294967295, parse("4294967295") # 2**32 - 1
  end

  def test_parse_fixnum_exponents
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
      assert_equal n, parse(n.to_s)
    end
  end

  def test_parse_float
    assert_equal 1.0, parse("1.0")
  end

  def test_parse_string
    assert_equal "", parse('""')
    assert_equal "1", parse('"1"')
    assert_equal "foo", parse('"foo"')
    assert_equal "abcdefghijklmnopqrstuvwxyz", parse('"abcdefghijklmnopqrstuvwxyz"')
  end

  def test_parse_invalida
    ex = assert_raises RapidJSON::ParseError do
      parse("abc")
    end
    assert_equal "JSON parse error: Invalid value. (0)", ex.message

    ex = assert_raises RapidJSON::ParseError do
      parse("[1,2,3,4,five]")
    end
    assert_equal "JSON parse error: Invalid value. (10)", ex.message
  end

  def test_parse_too_deep
    max = 256
    assert parse("["*max + "]"*max)
    assert_raises RapidJSON::ParseError do
      assert parse("["*(max+1) + "]"*(max+1))
    end
  end

  def test_parse_NaN_and_Infinity
    assert_raises RapidJSON::ParseError do
      parse("NaN")
    end

    assert_raises RapidJSON::ParseError do
      parse("Infinity")
    end

    assert_raises RapidJSON::ParseError do
      parse("-Infinity")
    end
  end

  def test_parse_NaN_and_Infinity_allowed
    coder = RapidJSON::Coder.new(allow_nan: true)

    assert_predicate coder.load("NaN"), :nan?
    assert_equal Float::INFINITY, coder.load("Inf")
    assert_equal -Float::INFINITY, coder.load("-Inf")
  end
end
