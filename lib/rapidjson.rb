# frozen_string_literal: true

require_relative "rapidjson/version"

module RapidJSON
  class Error < StandardError; end

  Fragment = Struct.new(:to_json)

  class Coder
    def initialize(pretty: false, allow_nan: false, &to_json)
      @pretty = pretty
      @to_json_proc = to_json
      @allow_nan = allow_nan
    end

    def dump(object)
      _dump(object, @pretty, @to_json_proc, @allow_nan)
    end

    def load(string)
      _load(string, @allow_nan)
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
      PRETTY_CODER.dump(object)
    end

    def valid_json?(string)
      DEFAULT_CODER.valid_json?(string)
    end
  end

  DEFAULT_CODER = Coder.new
  private_constant :DEFAULT_CODER

  PRETTY_CODER = Coder.new(pretty: true)
  private_constant :PRETTY_CODER
end

require "rapidjson/json_gem"
require "rapidjson/active_support_encoder"
