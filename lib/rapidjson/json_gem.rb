module ::Kernel
  def JSON(object, opts = {})
    if object.respond_to? :to_s
      JSON.parse(object.to_s)
    else
      JSON.generate(object, opts)
    end
  end
end

module JSON
  def self.generate(obj, opts=nil)
    RapidJSON.encode(obj)
  end

  def self.pretty_generate(obj, opts=nil)
    RapidJSON.pretty_encode(obj)
  end

  def self.dump(obj)
    RapidJSON.encode(obj)
  end
end

# to_json
module RapidJSON
  module JSONGemCompact
    def to_json(opts=nil)
      RapidJSON.encode(self)
    end
  end
end

[Hash, Array, String, Integer, Float, TrueClass, FalseClass, NilClass].each do |klass|
  klass.include RapidJSON::JSONGemCompact
end
