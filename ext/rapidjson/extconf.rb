# frozen_string_literal: true

require "mkmf"

submodule = "#{__dir__}/rapidjson"
$CXXFLAGS += " -O3 -I#{submodule}/include/ -Wall "

if ENV["DEBUG"]
$CXXFLAGS += " -Og -g -Wall -Wextra "
end

if ENV["SANITIZE"]
$CXXFLAGS += " -fsanitize=address"
$LDFLAGS += " -fsanitize=address"
end

have_func("rb_enc_interned_str", "ruby.h")

create_makefile("rapidjson/rapidjson")
