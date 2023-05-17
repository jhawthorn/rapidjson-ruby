#include "cext.hh"

#include "rapidjson/writer.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/error/en.h"

static VALUE rb_eParseError;
static VALUE rb_eEncodeError;

static ID id_to_json;
static ID id_to_s;

#include "encoder.hh"
#include "parser.hh"

using namespace rapidjson;

typedef RubyStringBuffer DefaultBuffer;

static VALUE
encode(VALUE _self, VALUE obj) {
    RubyObjectEncoder<DefaultBuffer, Writer<DefaultBuffer> > encoder;
    return encoder.encode(obj);
}

static VALUE
pretty_encode(VALUE _self, VALUE obj) {
    RubyObjectEncoder<DefaultBuffer, PrettyWriter<DefaultBuffer> > encoder;
    return encoder.encode(obj);
}

static VALUE
parse(VALUE _self, VALUE string) {
    RubyObjectHandler handler;
    Reader reader;
    char *cstring = StringValueCStr(string); // fixme?
    StringStream ss(cstring);
    ParseResult ok = reader.Parse(ss, handler);

    if (!ok) {
        rb_raise(rb_eParseError, "JSON parse error: %s (%lu)",
                GetParseError_En(ok.Code()), ok.Offset());
    }

    return handler.GetRoot();
}

static VALUE
valid_json_p(VALUE _self, VALUE string) {
    NullHandler handler;
    Reader reader;
    char *cstring = StringValueCStr(string); // fixme?
    StringStream ss(cstring);
    ParseResult ok = reader.Parse(ss, handler);

    if (!ok) {
        return Qfalse;
    }

    return Qtrue;
}

extern "C" void
Init_rapidjson(void)
{
    id_to_s = rb_intern("to_s");
    id_to_json = rb_intern("to_json");

    VALUE rb_mRapidJSON = rb_const_get(rb_cObject, rb_intern("RapidJSON"));
    rb_define_module_function(rb_mRapidJSON, "encode", encode, 1);
    rb_define_module_function(rb_mRapidJSON, "pretty_encode", pretty_encode, 1);
    rb_define_module_function(rb_mRapidJSON, "dump", encode, 1);

    rb_define_module_function(rb_mRapidJSON, "parse", parse, 1);
    rb_define_module_function(rb_mRapidJSON, "load", parse, 1);
    rb_define_module_function(rb_mRapidJSON, "valid_json?", valid_json_p, 1);

    VALUE rb_eRapidJSONError = rb_const_get(rb_mRapidJSON, rb_intern("Error"));
    rb_eParseError = rb_define_class_under(rb_mRapidJSON, "ParseError", rb_eRapidJSONError);
    rb_eEncodeError = rb_define_class_under(rb_mRapidJSON, "EncodeError", rb_eRapidJSONError);
}
