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
    enum class ObjectType : char {
        Array,
        BufferedHash,
        Hash,
    };

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
        return PutValue(rb_float_new(d));
    }

    bool String(const char* str, SizeType length, bool copy) {
        VALUE string = rb_enc_str_new(str, length, rb_utf8_encoding());
        return PutValue(string);
    }

    bool StartObject() {
        //return push(rb_hash_new());
        //return push(rb_hash_new(), ObjectType::Hash);
        return push(Qundef, ObjectType::BufferedHash);
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
        materialize_hash();
        return PutValue(pop());
    }

    bool StartArray() {
        VALUE array = rb_ary_new();
        return push(array, ObjectType::Array);
    }

    bool EndArray(SizeType elementCount) {
        VALUE val = pop();
        PutValue(val);
        return true;
    }

    void materialize_hash() {
        auto top_type = stack_type[depth - 1];

        if (top_type == ObjectType::BufferedHash) {
            if (hash_buffer_idx & 1) {
                // drop last key
                hash_buffer_idx--;
            }

            VALUE hash = rb_hash_new_capa(hash_buffer_idx / 2);
            rb_hash_bulk_insert(hash_buffer_idx, hash_buffer, hash);

            stack[depth - 1] = hash;
            stack_type[depth - 1] = ObjectType::Hash;
            hash_buffer_idx = 0;
        }
    }

    bool push(VALUE val, ObjectType type) {
        if (depth < MAX_DEPTH) {
            materialize_hash();

            stack[depth] = val;
            stack_type[depth] = type;
            depth++;
            return true;
        } else {
            rb_raise(rb_eParseError, "JSON parse error: input too deep");
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
            auto top_type = stack_type[depth - 1];

            if (top_type == ObjectType::BufferedHash) {
                if (hash_buffer_idx >= HASH_BUFFER_LEN) {
                    materialize_hash();
		    last_key[depth - 1] = key;
		    return true;
                }
                if (hash_buffer_idx & 1) {
                    rb_bug("rapidjson: key at odd offset");
                }
                hash_buffer[hash_buffer_idx++] = key;
                last_key[depth - 1] = key;
		return true;
            } else {
                last_key[depth - 1] = key;
		return true;
            }
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
            auto top_type = stack_type[depth - 1];
            switch(top_type) {
                case ObjectType::Array:
                    rb_ary_push(top_val, val);
                    break;
                case ObjectType::BufferedHash:
                    if (hash_buffer_idx >= HASH_BUFFER_LEN) {
                        rb_bug("rapidjson: FIXME: key would overflow buffer");
                    }
                    hash_buffer[hash_buffer_idx++] = val;
                    break;
                    materialize_hash();
                case ObjectType::Hash:
                    rb_hash_aset(top_val, last_key[depth - 1], val);
                    break;
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

    RubyObjectHandler(): depth(0), hash_buffer_idx(0) {
        stack[0] = Qundef;
    }

    static const int MAX_DEPTH = 256;
    int depth;
    VALUE stack[MAX_DEPTH];
    ObjectType stack_type[MAX_DEPTH];
    VALUE last_key[MAX_DEPTH];

    static const int HASH_BUFFER_LEN = 16;
    VALUE hash_buffer[HASH_BUFFER_LEN];
    int hash_buffer_idx;
};
