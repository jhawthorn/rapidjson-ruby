#pragma once

#include "rapidjson/writer.h"
#include "buffer.hh"

using namespace rapidjson;

template <typename B = RubyStringBuffer, typename W=Writer<B> >
class RubyObjectEncoder {
    B buf;
    VALUE as_json;
    bool allow_nan;

    void encode_array(VALUE ary) {
        writer.StartArray();
        int length = RARRAY_LEN(ary);
        RARRAY_PTR_USE(ary, ptr, {
                for (int i = 0; i < length; i++) {
                encode_any(ptr[i], true);
                }
                });
        writer.EndArray();
    }

    static VALUE string_to_utf8_compatible(VALUE str) {
        rb_encoding *enc = rb_enc_get(str);
        if (enc == rb_utf8_encoding() || enc == rb_usascii_encoding()) {
            return str;
        } else {
            return rb_str_export_to_enc(str, rb_utf8_encoding());
        }
    }

    void encode_key(VALUE key) {
        switch(rb_type(key)) {
            case T_STRING:
                break;
            case T_SYMBOL:
                key = rb_sym2str(key);
                break;
            case T_FIXNUM:
            case T_BIGNUM:
                key = rb_String(key);
                break;
            default:
                if (NIL_P(as_json)) {
                    rb_raise(rb_eTypeError, "Invalid object key type: %" PRIsVALUE, rb_obj_class(key));
                    UNREACHABLE_RETURN();
                }

                VALUE args[2] = { key, Qtrue };
                key = rb_proc_call_with_block(as_json, 2, args, Qnil);
                if (rb_obj_class(key) == rb_cRapidJSONFragment) {
                    VALUE str = rb_struct_aref(key, INT2FIX(0));
                    Check_Type(str, T_STRING);
                    return encode_raw_json_str(str);
                }

                break;
        }

        Check_Type(key, T_STRING);
        key = string_to_utf8_compatible(key);
        writer.Key(RSTRING_PTR(key), RSTRING_LEN(key), false);
    }

    static int encode_hash_i_cb(VALUE key, VALUE val, VALUE ctx) {
        RubyObjectEncoder *encoder = (RubyObjectEncoder *)ctx;
        encoder->encode_hash_i(key, val);
        return ST_CONTINUE;
    }

    void encode_hash_i(VALUE key, VALUE val) {
        encode_key(key);
        encode_any(val, true);
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
        // Some T_BIGNUM might be small enough to fit in long long or unsigned long long
        // but this being the slow path, it's not really worth it.
        VALUE str = rb_String(b);
        Check_Type(str, T_STRING);

        // We should be able to use RawNumber here, but it's buggy
        // https://github.com/Tencent/rapidjson/issues/852
        writer.RawValue(RSTRING_PTR(str), RSTRING_LEN(str), kNumberType);
    }

    void encode_float(VALUE v, bool generic) {
        double f = rb_float_value(v);
        if (!isfinite(f)) {
            if (!allow_nan && !NIL_P(as_json) && generic) {
                return encode_generic(v);
            }
            if (f == (-1.0 / 0.0)) {
                if (allow_nan) {
                    writer.RawValue("-Infinity", 9, kObjectType);
                } else {
                    rb_raise(rb_eEncodeError, "-Float::INFINITY is not allowed in JSON");
                }
            } else if (isinf(f)) {
                if (allow_nan) {
                    writer.RawValue("Infinity", 8, kObjectType);
                } else {
                    rb_raise(rb_eEncodeError, "Float::INFINITY is not allowed in JSON");
                }
            } else if (isnan(f)) {
                if (allow_nan) {
                    writer.RawValue("NaN", 3, kObjectType);
                } else {
                    rb_raise(rb_eEncodeError, "Float::NAN is not allowed in JSON");
                }
            }
        } else {
            writer.Double(f);
        }
    }

    void encode_string(VALUE v) {
        v = string_to_utf8_compatible(v);
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
        if (NIL_P(as_json)) {
            rb_raise(rb_eTypeError, "Don't know how to serialize %" PRIsVALUE " to JSON", rb_obj_class(obj));
            UNREACHABLE_RETURN();
        }

        VALUE args[2] = { obj, Qfalse };
        encode_any(rb_proc_call_with_block(as_json, 2, args, Qnil), false);
    }

    void encode_any(VALUE v, bool generic) {
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
                return encode_float(v, generic);
            case T_HASH:
                return encode_hash(v);
            case T_ARRAY:
                return encode_array(v);
            case T_STRING:
                return encode_string(v);
            case T_SYMBOL:
                return encode_symbol(v);
            case T_STRUCT:
                if (rb_obj_class(v) == rb_cRapidJSONFragment) {
                    VALUE str = rb_struct_aref(v, INT2FIX(0));
                    Check_Type(str, T_STRING);
                    return encode_raw_json_str(str);
                }
                // fall through
            default:
                if (generic) {
                    encode_generic(v);
                } else {
                    rb_raise(rb_eTypeError, "Don't know how to serialize %" PRIsVALUE " to JSON", rb_obj_class(v));
                }
        }
    }

    public:
        RubyObjectEncoder(VALUE as_json_proc, bool allow_nan_): buf(), writer(buf), depth(0) {
            as_json = as_json_proc;
            allow_nan = allow_nan_;
        };

        W writer;
        int depth;

        VALUE encode(VALUE obj) {
            encode_any(obj, true);
            return buf.GetRubyString();
        }

        struct protected_args {
            RubyObjectEncoder *encoder;
            VALUE obj;
        };

        static VALUE encode_protected_cb(VALUE data) {
            struct protected_args *args = (struct protected_args *)data;
            return args->encoder->encode(args->obj);
        }

        VALUE encode_protected(VALUE obj, int *state) {
            struct protected_args args = { this, obj };
            return rb_protect(encode_protected_cb, (VALUE)&args, state);
        }
};
