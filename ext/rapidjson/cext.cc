#include "cext.hh"

#include "rapidjson/writer.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/error/en.h"

static VALUE rb_eParseError;
static VALUE rb_eEncodeError;
static VALUE rb_cRapidJSONFragment;

#include "encoder.hh"
#include "parser.hh"
#include "json_escape.h"

using namespace rapidjson;

typedef RubyStringBuffer DefaultBuffer;

static VALUE
dump(VALUE _self, VALUE obj, VALUE pretty, VALUE as_json, VALUE allow_nan) {
    // NB: as_json here is not marked by the extension, but is always on the stack
    VALUE result;
    int state;

    if (RTEST(pretty)) {
        RubyObjectEncoder<DefaultBuffer, PrettyWriter<DefaultBuffer> > encoder(as_json, RTEST(allow_nan));
        encoder.writer.SetIndent(' ', 2);
        result = encoder.encode_protected(obj, &state);
    } else {
        RubyObjectEncoder<DefaultBuffer, Writer<DefaultBuffer> > encoder(as_json, RTEST(allow_nan));
        result = encoder.encode_protected(obj, &state);
    }

    if (state) {
        rb_jump_tag(state);
    }
    return result;
}

static VALUE
load(VALUE _self, VALUE string, VALUE allow_nan) {
    RubyObjectHandler handler(RTEST(allow_nan));
    ParseResult ok;

    {
        char *cstring = StringValueCStr(string); // fixme?
        StringStream ss(cstring);
        Reader reader;
        ok = reader.Parse<kParseNanAndInfFlag>(ss, handler);
    }

    if (!ok) {
        VALUE err = handler.GetErr();
        if (RTEST(err)) {
            rb_exc_raise(err);
        } else {
            rb_raise(rb_eParseError, "JSON parse error: %s (%lu)",
                    GetParseError_En(ok.Code()), ok.Offset());
        }
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
    VALUE rb_mRapidJSON = rb_const_get(rb_cObject, rb_intern("RapidJSON"));
    VALUE rb_cCoder = rb_const_get(rb_mRapidJSON, rb_intern("Coder"));
    rb_cRapidJSONFragment = rb_const_get(rb_mRapidJSON, rb_intern("Fragment"));;
    rb_global_variable(&rb_cRapidJSONFragment);

    rb_define_private_method(rb_cCoder, "_dump", dump, 4);
    rb_define_method(rb_cCoder, "_load", load, 2);
    rb_define_method(rb_cCoder, "valid_json?", valid_json_p, 1);

    VALUE rb_eRapidJSONError = rb_const_get(rb_mRapidJSON, rb_intern("Error"));
    rb_eParseError = rb_define_class_under(rb_mRapidJSON, "ParseError", rb_eRapidJSONError);
    rb_eEncodeError = rb_define_class_under(rb_mRapidJSON, "EncodeError", rb_eRapidJSONError);

    rb_define_singleton_method(rb_mRapidJSON, "json_escape", escape_json, 1);
}
