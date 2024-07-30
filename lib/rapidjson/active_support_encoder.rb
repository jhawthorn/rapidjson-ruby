module RapidJSON
  class ActiveSupportEncoder
    def initialize(options = nil)
      @options = options
      @coder = RapidJSON::Coder.new do |value, is_key|
        if is_key
          value.to_s
        else
          value.as_json
        end
      end
    end

    # Encode the given object into a JSON string
    def encode(value)
      if @options && !@options.empty?
        if !RapidJSON.json_ready?(value) || @options.key?(:only) || @options.key?(:except)
          value = value.as_json(@options.dup)
        end
      end
      json = @coder.dump(value)
      if ActiveSupport::JSON::Encoding.escape_html_entities_in_json
        json = RapidJSON.json_escape(json)
      end
      json
    end
  end
end
