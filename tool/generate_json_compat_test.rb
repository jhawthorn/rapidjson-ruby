require "erb"

# original JSON gem
require "json"

DATA_DIR = File.expand_path("../../test/data/", __FILE__)
TEST_FILES = []
TEST_FILES.concat Dir["#{DATA_DIR}/JSONTestSuite/test_parsing/y_*.json"]
TEST_FILES.concat Dir["#{DATA_DIR}/JSONTestSuite/test_transform/*.json"]

# FIXME: include these?
#TEST_FILES.concat Dir["#{DATA_DIR}/JSONTestSuite/test_parsing/i_*.json"]

TEST_FILES.select! do |filename|
  JSON.parse(File.read(filename))
  true
rescue JSON::ParserError
  false
end

TestCase = Struct.new(:filename) do
  def name
    File.basename(filename, ".json")
  end

  def method_name
    @method_name ||= name.gsub(/[^a-zA-Z0-9]+/, "_").gsub(/\Ay_/, "")
  end

  def original_json
    File.read(filename)
  end

  def expected_parse
    JSON.parse(original_json)
  end

  def src
    <<~TEST
      define_method(:"test_#{name.inspect}") do
        json = #{original_json.inspect}
        expected = #{expected_parse.inspect}
      end
    TEST
  end
end

TEST_CASES = TEST_FILES.map do |file|
  TestCase.new(file)
end

TEST_CASES.group_by(&:method_name).each_value do |group|
  next if group.size <= 1
  group.each_with_index do |test, i|
    test.method_name << "_#{i+1}"
  end
end

EXCLUDED_TESTS = [
  "string_2_escaped_invalid_codepoints", # We reject these codepoints
  "number_-9223372036854775809" # JSON makes -(2**64) a float
]
TEST_CASES.reject! do |test|
  EXCLUDED_TESTS.include?(test.name)
end

erb = ERB.new(DATA.read, trim_mode: "%")
puts erb.result(binding)

__END__
# This file is generated by <%= $0 %>

require "test_helper"

class JSONCompatTest < Minitest::Test
% TEST_CASES.each_with_index do |test, i|
  def test_<%= test.method_name %>
    expected = <%= test.expected_parse.inspect %>
    json = <%= test.original_json.inspect %>
    assert_json expected, json
  end

% end
  private

  def assert_json(expected, json)
    actual = RapidJSON.parse(json)
    if expected.nil?
      assert_nil actual
    else
      assert_equal expected, actual
    end
  end
end
