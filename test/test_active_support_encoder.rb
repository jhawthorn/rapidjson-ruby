# frozen_string_literal: true

require "test_helper"

# Sorry
unless defined?(ActiveSupport::JSON::Encoding)
  module ActiveSupport
    module JSON
      module Encoding
        class << self
          attr_accessor :escape_html_entities_in_json
        end
        self.escape_html_entities_in_json = false
      end
    end
  end
end

class TestActiveSupportEncoder < Minitest::Test
  class AsJSON
    def initialize value
      @as_json = value.freeze
    end

    def as_json(options = nil)
      @as_json
    end
  end

  class ReturnOptions
    def as_json(options = nil)
      options
    end
  end

  class ToString
    def initialize value
      @to_s = value
    end

    attr_reader :to_s
  end

  def encode(value, options = nil)
    RapidJSON::ActiveSupportEncoder.new(options).encode(value)
  end

  def test_basic_types
    assert_equal "true", encode(true)
    assert_equal "false", encode(false)
    assert_equal "null", encode(nil)
    assert_equal "1", encode(1)
    assert_equal "2.5", encode(2.5)
    assert_equal %q{"foo"}, encode("foo")

    assert_equal "[]", encode([])
    assert_equal %q{["foo"]}, encode(["foo"])
    assert_equal %q{["foo"]}, encode([:foo])

    assert_equal "{}", encode({})
    assert_equal %q{{"key":"value"}}, encode({"key" => "value"})
    assert_equal %q{{"key":"value"}}, encode({key: :value})

    ex = assert_raises NoMethodError do
      encode(BasicObject.new)
    end
    assert_includes ex.message, "as_json"
  end

  def test_as_json_values
    assert_equal %q{"foo"}, encode(AsJSON.new("foo"))
    assert_equal "null", encode(AsJSON.new(nil))
    assert_equal "[]", encode(AsJSON.new([]))

    assert_equal %q{["success"]}, encode(AsJSON.new([AsJSON.new("success")]))
    assert_equal %q{{"success":"yes!"}}, encode(AsJSON.new({success: AsJSON.new("yes!")}))

    ex = assert_raises TypeError do
      encode(AsJSON.new(AsJSON.new("bad")))
    end
    assert_equal "Don't know how to serialize TestActiveSupportEncoder::AsJSON to JSON", ex.message
  end

  def test_to_s_keys
    assert_equal %q{{"foo":"ok"}}, encode(ToString.new("foo") => "ok")

    ex = assert_raises TypeError do
      encode(ToString.new([]) => "bad")
    end
    assert_equal "wrong argument type Array (expected String)", ex.message
  end

  def test_options
    assert_equal "null", encode(ReturnOptions.new)
    assert_equal "null", encode(ReturnOptions.new, {})

    assert_equal %q{{"include":"foo"}}, encode(ReturnOptions.new, { include: :foo })
    assert_equal %q{null}, encode(AsJSON.new(ReturnOptions.new), { include: :foo })
    assert_equal %q{[null]}, encode(AsJSON.new([ReturnOptions.new]), { include: :foo })
  end
end
