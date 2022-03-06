#include "cext.hh"

VALUE rb_mRapidjson;

#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"
#include <iostream>

using namespace rapidjson;
using namespace std;

class RubyObjectEncoder {
    StringBuffer buf;
    Writer<StringBuffer> writer;

    void test() {
        writer.StartObject();
        writer.Key("hello");
        writer.String("world");
        writer.Key("t");
        writer.Bool(true);
        writer.Key("f");
        writer.Bool(false);
        writer.Key("n");
        writer.Null();
        writer.Key("i");
        writer.Uint(123);
        writer.Key("pi");
        writer.Double(3.1416);
        writer.Key("a");
        writer.StartArray();
        for (unsigned i = 0; i < 4; i++)
            writer.Uint(i);
        writer.EndArray();
        writer.EndObject();
    }

    public:
        RubyObjectEncoder(): depth(0), buf(), writer(buf) {
        };

        int depth;

        VALUE encode() {
            test();
            VALUE ruby_string = rb_str_new(buf.GetString(), buf.GetSize());
            return ruby_string;
        }
};

VALUE encode(VALUE _self, VALUE obj) {
    RubyObjectEncoder encoder;
    return encoder.encode();
}

extern "C" void
Init_rapidjson(void)
{
    rb_mRapidjson = rb_define_module("RapidJSON");
    rb_define_module_function(rb_mRapidjson, "encode", encode, 1);
    rb_define_module_function(rb_mRapidjson, "dump", encode, 1);
}
