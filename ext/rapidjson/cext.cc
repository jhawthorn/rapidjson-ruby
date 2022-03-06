#include "cext.hh"

VALUE rb_mRapidjson;

#include "rapidjson/writer.h"
#include "rapidjson/prettywriter.h"

#include "encoder.hh"

using namespace rapidjson;

typedef RubyStringBuffer DefaultBuffer;

VALUE encode(VALUE _self, VALUE obj) {
    RubyObjectEncoder encoder;
    return encoder.encode(obj);
}

VALUE pretty_encode(VALUE _self, VALUE obj) {
    RubyObjectEncoder<DefaultBuffer, PrettyWriter<DefaultBuffer>> encoder;
    return encoder.encode(obj);
}

extern "C" void
Init_rapidjson(void)
{
    rb_mRapidjson = rb_define_module("RapidJSON");
    rb_define_module_function(rb_mRapidjson, "encode", encode, 1);
    rb_define_module_function(rb_mRapidjson, "pretty_encode", pretty_encode, 1);
    rb_define_module_function(rb_mRapidjson, "dump", encode, 1);
}
