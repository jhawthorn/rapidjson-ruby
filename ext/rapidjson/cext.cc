#include "cext.hh"

#include "rapidjson/writer.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/error/en.h"

static VALUE rb_mRapidJSON;
static VALUE rb_eParseError;
static VALUE rb_eEncodeError;

static VALUE rb_LLONG_MIN = Qnil, rb_ULLONG_MAX = Qnil;

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
    // TODO: rapidjson::kParseInsituFlag ?
    ParseResult ok = reader.Parse<rapidjson::kParseNumbersAsStringsFlag>(ss, handler);

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

    rb_global_variable(&rb_LLONG_MIN);
    rb_global_variable(&rb_ULLONG_MAX);

    rb_LLONG_MIN = LL2NUM(LLONG_MIN);
    rb_ULLONG_MAX = ULL2NUM(ULLONG_MAX);

    rb_mRapidJSON = rb_define_module("RapidJSON");
    rb_define_module_function(rb_mRapidJSON, "encode", encode, 1);
    rb_define_module_function(rb_mRapidJSON, "pretty_encode", pretty_encode, 1);
    rb_define_module_function(rb_mRapidJSON, "dump", encode, 1);

    rb_define_module_function(rb_mRapidJSON, "parse", parse, 1);
    rb_define_module_function(rb_mRapidJSON, "load", parse, 1);
    rb_define_module_function(rb_mRapidJSON, "valid_json?", valid_json_p, 1);

    rb_eParseError = rb_define_class_under(rb_mRapidJSON, "ParseError", rb_eStandardError);
    rb_eEncodeError = rb_define_class_under(rb_mRapidJSON, "EncodeError", rb_eStandardError);
}
