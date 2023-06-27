#include <iostream>

using namespace std;

class RubyStringBuffer {
    public:
        typedef char Ch;

        RubyStringBuffer() : used(0), capacity(INITIAL_SIZE) {
            ruby_string = rb_str_buf_new(INITIAL_SIZE);
            rb_enc_associate(ruby_string, rb_utf8_encoding());
            mem = RSTRING_PTR(ruby_string);
        }

        void Reserve(size_t want) {
            if (capacity - used < want) {
                size_t new_capacity = capacity;
                while (new_capacity - used < want) {
                    if (new_capacity >= SIZE_MAX / 2) {
                        ruby_malloc_size_overflow(capacity, 2);
                    }
                    new_capacity <<= 1;
                }
                resize(new_capacity);
            }
        }

        void PutUnsafe(Ch c) {
            mem[used++] = c;
        }

        void Put(Ch c) {
            Reserve(1);
            PutUnsafe(c);
        }

        void Flush() {
            rb_str_set_len(ruby_string, used);
        }

        VALUE GetRubyString() {
            return ruby_string;
        }

    private:
        void resize(size_t newcap) {
            rb_str_modify_expand(ruby_string, newcap);
            mem = RSTRING_PTR(ruby_string);
            capacity = newcap;
        }

        static const size_t INITIAL_SIZE = 2048;

        VALUE ruby_string;

        size_t used;
        size_t capacity;
        char *mem;

        RubyStringBuffer(const RubyStringBuffer&);
        RubyStringBuffer& operator=(const RubyStringBuffer&);
};

inline void PutReserve(RubyStringBuffer &stream, size_t count) {
    stream.Reserve(count);
}

inline void PutUnsafe(RubyStringBuffer &stream, char c) {
    stream.PutUnsafe(c);
}

//inline void PutN(RubyStringBuffer &stream, char c, size_t n) {
//    std::memset(stream..Push<char>(n), c, n * sizeof(c));
//}
