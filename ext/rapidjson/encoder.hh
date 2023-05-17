#pragma once

#include "rapidjson/writer.h"
#include "buffer.hh"

using namespace rapidjson;

template <typename B = RubyStringBuffer, typename W=Writer<B> >
class RubyObjectEncoder {
    B buf;
    W writer;

    void encode_array(VALUE ary) {
        writer.StartArray();
        int length = RARRAY_LEN(ary);
        RARRAY_PTR_USE(ary, ptr, {
                for (int i = 0; i < length; i++) {
                encode_any(ptr[i]);
                }
                });
        writer.EndArray();
    }

    void encode_key(VALUE key) {
        switch(rb_type(key)) {
            case T_SYMBOL:
                key = rb_sym2str(key);
                /* FALLTHRU */
            case T_STRING:
                writer.Key(RSTRING_PTR(key), RSTRING_LEN(key), false);
                return;
            default:
                {
                    VALUE str = rb_funcall(key, id_to_s, 0);
                    Check_Type(str, T_STRING);
                    encode_string(str);
                }
        }
    }

    static int encode_hash_i_cb(VALUE key, VALUE val, VALUE ctx) {
        RubyObjectEncoder *encoder = (RubyObjectEncoder *)ctx;
        encoder->encode_hash_i(key, val);
        return ST_CONTINUE;
    }

    void encode_hash_i(VALUE key, VALUE val) {
        encode_key(key);
        encode_any(val);
    }

    void encode_hash(VALUE hash) {
        writer.StartObject();
        rb_hash_foreach(hash, encode_hash_i_cb, (VALUE)this);
        writer.EndObject();
    }

    void encode_fixnum(VALUE v) {
        writer.Int64(FIX2LONG(v));
    }

    void encode_bignum(VALUE b) {
        b = rb_big_norm(b);
        if (FIXNUM_P(b)) {
            return encode_fixnum(b);
        }

        bool negative = rb_big_cmp(b, INT2FIX(0)) == INT2FIX(-1);
        if (negative) {
            if (rb_big_cmp(b, rb_LLONG_MIN) != INT2FIX(-1)) {
                long long ll = rb_big2ll(b);
                writer.Int64(ll);
                return;
            }
        } else if (rb_big_cmp(b, rb_ULLONG_MAX) == INT2FIX(-1)) {
            unsigned long long ull = rb_big2ull(b);
            writer.Uint64(ull);
            return;
        }

        // If the number is too big, we go through Integer#to_s
        VALUE str = rb_funcall(b, id_to_s, 0);
        Check_Type(str, T_STRING);

        // We should be able to use RawNumber here, but it's buggy
        // https://github.com/Tencent/rapidjson/issues/852
        writer.RawValue(RSTRING_PTR(str), RSTRING_LEN(str), kNumberType);
    }

    void encode_float(VALUE v) {
        double f = rb_float_value(v);
        if (isinf(f)) {
            rb_raise(rb_eEncodeError, "Float::INFINITY is not allowed in JSON");
        } else if (isnan(f)) {
            rb_raise(rb_eEncodeError, "Float::NAN is not allowed in JSON");
        } else {
            writer.Double(f);
        }
    }

    void encode_string(VALUE v) {
        writer.String(RSTRING_PTR(v), RSTRING_LEN(v), false);
    }

    void encode_symbol(VALUE v) {
        encode_string(rb_sym2str(v));
    }

    void encode_raw_json_str(VALUE s) {
        const char *cstr = RSTRING_PTR(s);
        size_t len = RSTRING_LEN(s);

	writer.RawValue(cstr, len, kObjectType);
    }

    void encode_generic(VALUE obj) {
        if (rb_respond_to(obj, id_to_json)) {
            VALUE str = rb_funcall(obj, id_to_json, 0);
            Check_Type(str, T_STRING);
            encode_raw_json_str(str);
        } else {
            VALUE str = rb_funcall(obj, id_to_s, 0);
            Check_Type(str, T_STRING);
            encode_string(str);
        }
    }

    void encode_any(VALUE v) {
        switch(rb_type(v)) {
            case T_NIL:
                writer.Null();
                return;
            case T_FALSE:
                writer.Bool(false);
                return;
            case T_TRUE:
                writer.Bool(true);
                return;
            case T_FIXNUM:
                return encode_fixnum(v);
            case T_BIGNUM:
                return encode_bignum(v);
            case T_FLOAT:
                return encode_float(v);
            case T_HASH:
                return encode_hash(v);
            case T_ARRAY:
                return encode_array(v);
            case T_STRING:
                return encode_string(v);
            case T_SYMBOL:
                return encode_symbol(v);
            default:
                encode_generic(v);
        }
    }

    public:
        RubyObjectEncoder(): buf(), writer(buf), depth(0) {
        };

        int depth;

        VALUE encode(VALUE obj) {
            encode_any(obj);
            return buf.GetRubyString();
        }
};
