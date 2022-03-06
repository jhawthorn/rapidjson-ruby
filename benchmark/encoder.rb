require "benchmark/ips"
require "json"
require "oj"
require "yajl"
require "rapidjson"

if ENV["ONLY"]
  RUN = ENV["ONLY"].split(/[,: ]/).map{|x| [x.to_sym, true] }.to_h
  RUN.default = false
elsif ENV["EXCEPT"]
  RUN = ENV["only"].split(/[,: ]/).map{|x| [x.to_sym, false] }.to_h
  RUN.default = true
else
  RUN = Hash.new(true)
end

def benchmark_encoding(name, ruby_obj)
  json_output = JSON.dump(ruby_obj)
  puts "== Encoding #{name} (#{json_output.size} bytes)"

  Benchmark.ips do |x|
    x.report("yajl")      { Yajl::Encoder.new.encode(ruby_obj) } if RUN[:yajl]
    x.report("json")      { JSON.dump(ruby_obj) } if RUN[:json]
    x.report("oj")        { Oj.dump(ruby_obj) } if RUN[:oj]
    x.report("rapidjson") { RapidJSON.encode(ruby_obj) } if RUN[:rapidjson]
  end
  puts
end

benchmark_encoding "small nested array", [[1,2,3,4,5]]*10
benchmark_encoding "small hash", { "username" => "jhawthorn", "id" => 123, "event" => "wrote json serializer" }
benchmark_encoding "canada.json", JSON.load_file("#{__dir__}/../test/data/canada.json")
