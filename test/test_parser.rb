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
end
