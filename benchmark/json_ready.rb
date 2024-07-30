require "benchmark/ips"
require "rapidjson"

if ENV["ONLY"]
  RUN = ENV["ONLY"].split(/[,: ]/).map{|x| [x.to_sym, true] }.to_h
  RUN.default = false
elsif ENV["EXCEPT"]
  RUN = ENV["EXCEPT"].split(/[,: ]/).map{|x| [x.to_sym, false] }.to_h
  RUN.default = true
else
  RUN = Hash.new(true)
end

class TrueClass; def as_json(options=nil) = self; end
class NilClass; def as_json(options=nil) = self; end
class FalseClass; def as_json(options=nil) = self; end
class Numeric; def as_json(options=nil) = self; end
class String; def as_json(options=nil) = self; end
class Symbol; def as_json(options=nil) = self; end
class Array
  def as_json(options=nil) = map(&:as_json)
end
class Hash
  def as_json(options=nil) = transform_values(&:as_json)
end


class TrueClass; def json_ready_method(options=nil) = true; end
class NilClass; def json_ready_method(options=nil) = true; end
class FalseClass; def json_ready_method(options=nil) = true; end
class Numeric; def json_ready_method(options=nil) = true; end
class String; def json_ready_method(options=nil) = true; end
class Symbol; def json_ready_method(options=nil) = true; end
class Array
  def json_ready_method(options=nil)
    each do |v|
      return false unless v.json_ready_method
    end
    true
  end
end
class Hash
  def json_ready_method(options=nil)
    each do |k, v|
      return false unless String === k || Symbol === k
      return false unless v.json_ready_method
    end
    true
  end
end

class RefinementJsonReady
  using Module.new {

    [Integer, Float, String, Symbol, NilClass, TrueClass, FalseClass].each do |klass|
      refine klass do
        def json_ready?; true; end
      end
    end

    refine Array do
      def json_ready?
        each { |obj| return false unless obj.json_ready? }
        true
      end
    end

    refine Hash do
      def json_ready?
        each do |key, value|
          return false unless String === key || Symbol === key
          return false unless value.json_ready?
        end
        true
      end
    end

    refine Object do
      def json_ready?
        false
      end
    end
  }

  def self.json_ready?(obj)
    obj.json_ready?
  end
end

class PureJsonReady
  def self.json_ready?(obj)
    case obj
    when true, false, nil, Integer, Float, String, Symbol
      true
    when Array
      obj.each { |obj| return false unless json_ready?(obj) }
      true
    when Hash
      obj.each do |key, value|
        return false unless String === key || Symbol === key
        return false unless json_ready?(value)
      end
      true
    else
      false
    end
  end
end

def benchmark_json_ready(benchmark_name, ruby_obj, check_expected: true)
  puts "== json_ready? #{benchmark_name}"

  raise "pure not json ready??" unless PureJsonReady.json_ready?(ruby_obj)
  raise "refinements not json ready??" unless RefinementJsonReady.json_ready?(ruby_obj)
  p RefinementJsonReady.json_ready?(ruby_obj)
  raise "RapidJSON not json ready??" unless RapidJSON.json_ready?(ruby_obj)

  Benchmark.ips do |x|
    x.report "pure" do
      PureJsonReady.json_ready?(ruby_obj)
    end

    x.report "refinements" do
      RefinementJsonReady.json_ready?(ruby_obj)
    end

    x.report "rapidjson" do
      RapidJSON.json_ready?(ruby_obj)
    end

    x.report "json_ready_method" do
      ruby_obj.json_ready_method
    end

    x.report "as_json" do
      ruby_obj.as_json
    end

    x.compare!(order: :baseline)
  end
  puts
end

benchmark_json_ready "small nested array", [[1,2,3,4,5]]*10
benchmark_json_ready "small hash", { "username" => "jhawthorn", "id" => 123, "event" => "wrote json serializer" }
benchmark_json_ready "twitter.json", JSON.load_file("#{__dir__}/../test/data/twitter.json")
benchmark_json_ready "citm_catalog.json", JSON.load_file("#{__dir__}/../test/data/citm_catalog.json")
benchmark_json_ready "canada.json", JSON.load_file("#{__dir__}/../test/data/canada.json"), check_expected: false
