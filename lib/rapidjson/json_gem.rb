require "json"

module RapidJSON
  module JSONGem
    GeneratorError = RapidJSON::EncodeError

    GEM = ::JSON
    private_constant :GEM

    STATE = ::JSON::State.new
    private_constant :STATE

    TO_JSON_PROC = lambda do |object, is_key|
      if !is_key && object.respond_to?(:to_json)
        if Float === object
          # Avoid calling .to_json on NaN/Infinity/-Infinity
          # Prefers our exception to one raised by ::JSON
          object
        else
          Fragment.new(object.to_json(STATE))
        end
      elsif object.respond_to?(:to_s)
        object.to_s
      else
        raise TypeError, "Can't serialize #{object.class} to JSON"
      end
    end
    private_constant :TO_JSON_PROC

    GENERATE_CODER = Coder.new(&TO_JSON_PROC)
    private_constant :GENERATE_CODER

    DUMP_CODER = Coder.new(allow_nan: true, &TO_JSON_PROC)
    private_constant :DUMP_CODER

    PRETTY_CODER = Coder.new(pretty: true, &TO_JSON_PROC)
    private_constant :PRETTY_CODER

    # Note, we very explictly fallback to the JSON gem when we receive unknown options.
    # Unknown options may be required for security reasons (e.g. escape_slash: true)
    # so ignoring them could lead to security vulnerabilities.
    class << self
      def load(string, proc = nil, options = nil)
        if proc.nil? && options.nil?
          DEFAULT_CODER.load(string)
        else
          GEM.load(string, proc, options)
        end
      end

      def parse(string, opts = nil)
        if opts.nil?
          DEFAULT_CODER.load(string)
        else
          GEM.load(string, options)
        end
      end

      def dump(object, anIO = nil, limit = nil)
        if anIO.nil? && limit.nil?
          DUMP_CODER.dump(object)
        else
          GEM.dump(object, anIO, limit)
        end
      end

      def generate(object, opts = nil)
        if opts.nil?
          GENERATE_CODER.dump(object)
        else
          GEM.generate(object, opts)
        end
      end

      private

      def method_missing(name, *args)
        GEM.public_send(name, *args)
      end
      ruby2_keywords :method_missing

      def respond_to_missing?(name, include_private = false)
        GEM.respond_to?(name, include_private)
      end
    end
  end
end
