#pragma once

#include "cext.hh"

#include "rapidjson/reader.h"

using namespace rapidjson;

class NullHandler : public BaseReaderHandler<UTF8<>, NullHandler> {
    static const int MAX_DEPTH = 256;
    int depth;
    bool push() {
        return depth++ < MAX_DEPTH;
    }
    bool pop() {
        return depth-- > 0;
    }
    public:
    NullHandler(): depth(0) {
    }
    bool StartObject() { return push(); }
    bool EndObject(SizeType s) { return pop(); }
    bool StartArray() { return push(); }
    bool EndArray(SizeType s) { return pop(); }
};

struct RubyObjectHandler : public BaseReaderHandler<UTF8<>, RubyObjectHandler> {
    bool Null() {
        return PutValue(Qnil);
    }

    bool Bool(bool b) {
        return PutValue(b ? Qtrue : Qfalse);
    }

    bool Int(int i) {
        return PutValue(INT2FIX(i));
    }

    bool Uint(unsigned u) {
        return PutValue(INT2FIX(u));
    }

    bool Int64(int64_t i) {
        return PutValue(RB_LONG2NUM(i));
    }

    bool Uint64(uint64_t u) {
        return PutValue(RB_ULONG2NUM(u));
    }

    bool Double(double d) {
        if (!isfinite(d) && !allow_nan) {
            err = rb_exc_new_cstr(rb_eParseError, "JSON parse error: Invalid float value");
            return false;
        }
        return PutValue(rb_float_new(d));
    }

    bool String(const char* str, SizeType length, bool copy) {
        VALUE string = rb_enc_str_new(str, length, rb_utf8_encoding());
        return PutValue(string);
    }

    bool StartObject() {
        return push(rb_hash_new());
    }

    bool Key(const char* str, SizeType length, bool copy) {
#ifdef HAVE_RB_ENC_INTERNED_STR
        VALUE val = rb_enc_interned_str(str, length, rb_utf8_encoding());
#else
        VALUE val = rb_enc_str_new(str, length, rb_utf8_encoding());
#endif
        return PutKey(val);
    }

    bool EndObject(SizeType memberCount) {
        return PutValue(pop());
    }

    bool StartArray() {
        VALUE array = rb_ary_new();
        return push(array);
    }

    bool EndArray(SizeType elementCount) {
        VALUE val = pop();
        PutValue(val);
        return true;
    }

    bool push(VALUE val) {
        if (depth < MAX_DEPTH) {
            stack[depth] = val;
            depth++;
            return true;
        } else {
            err = rb_exc_new_cstr(rb_eParseError, "JSON parse error: input too deep");
            return false;
        }
    }

    VALUE pop() {
        if (depth > 0) {
            return stack[--depth];
        } else {
            rb_bug("rapidjson: tried to pop an empty stack");
            return Qundef;
        }
    }

    bool PutKey(VALUE key) {
        if (depth > 0) {
            last_key[depth - 1] = key;
            return true;
        } else {
            rb_bug("rapidjson: key at depth 0");
            return false;
        }
    }

    bool PutValue(VALUE val) {
        if (depth == 0) {
            stack[0] = val;
        } else {
            VALUE top_val = stack[depth - 1];
            if (RB_TYPE_P(top_val, T_ARRAY)) {
                rb_ary_push(top_val, val);
            } else if (RB_TYPE_P(top_val, T_HASH)) {
                rb_hash_aset(top_val, last_key[depth - 1], val);
            } else {
                rb_bug("rapidjson: bad type on stack");
            }
        }
        return true;
    }

    VALUE GetRoot() {
        VALUE val = stack[0];
        if (depth != 0 || val == Qundef) {
            rb_bug("rapidjson: bad root on stack");
        }
        return stack[0];
    }

    VALUE GetErr() {
        return err;
    }

    RubyObjectHandler(bool allow_nan): err(Qfalse), depth(0), allow_nan(allow_nan) {
        stack[0] = Qundef;
    }

    static const int MAX_DEPTH = 256;
    VALUE stack[MAX_DEPTH];
    VALUE last_key[MAX_DEPTH];
    VALUE err;
    int depth;
    bool allow_nan;
};
