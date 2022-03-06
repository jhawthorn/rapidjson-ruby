# frozen_string_literal: true

require "mkmf"

submodule = "#{__dir__}/rapidjson"
$CXXFLAGS += " -O3 -I#{submodule}/include/ -Wall "

create_makefile("rapidjson/rapidjson")
