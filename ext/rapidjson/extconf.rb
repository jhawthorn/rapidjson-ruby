# frozen_string_literal: true

require "mkmf"

submodule = "#{__dir__}/rapidjson"
$CXXFLAGS += " -I#{submodule}/include/ "

create_makefile("rapidjson/rapidjson")
