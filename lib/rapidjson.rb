# frozen_string_literal: true

require_relative "rapidjson/version"

module RapidJSON
  class Error < StandardError; end

  Fragment = Struct.new(:to_json)

  STDLIB_TO_JSON_PROC = lambda do |object, is_key|
    if !is_key && object.respond_to?(:to_json)
      Fragment.new(object.to_json)
    elsif object.respond_to?(:to_s)
      object.to_s
    else
      raise TypeError, "Can't serialize #{object.class} to JSON"
    end
  end
  private_constant :STDLIB_TO_JSON_PROC

  class Coder
    def initialize(pretty: false, &to_json)
      @pretty = pretty
      @to_json_proc = to_json
    end

    def dump(object)
      _dump(object, @pretty, @to_json_proc)
    end
  end
end

require_relative "rapidjson/rapidjson"

module RapidJSON
  class << self
    def load(string)
      DEFAULT_CODER.load(string)
    end
    alias_method :parse, :load

    def dump(object)
      DEFAULT_CODER.dump(object)
    end
    alias_method :encode, :dump

    def pretty_encode(object)
      PRETTY_CODER.encode(object)
    end

    def valid_json?(string)
      DEFAULT_CODER.valid_json?(string)
    end
  end

  DEFAULT_CODER = Coder.new(&STDLIB_TO_JSON_PROC)
  private_constant :DEFAULT_CODER

  PRETTY_CODER = Coder.new(pretty: true, &STDLIB_TO_JSON_PROC)
  private_constant :PRETTY_CODER
end
