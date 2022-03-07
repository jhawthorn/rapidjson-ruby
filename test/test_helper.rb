# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rapidjson"
require "rbconfig/sizeof"

DATA_DIR = "#{__dir__}/data"

require "minitest/autorun"
