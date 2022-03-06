#include <iostream>

using namespace std;

class RubyStringBuffer {
    public:
        typedef char Ch;

        RubyStringBuffer() : used(0), capacity(INITIAL_SIZE) {
            ruby_string = rb_str_buf_new(INITIAL_SIZE);
            mem = RSTRING_PTR(ruby_string);
        }

        void Put(Ch c) {
            if (used == capacity) {
                resize(capacity * 2);
            }

            mem[used++] = c;
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

        const size_t INITIAL_SIZE = 2048;

        VALUE ruby_string;

        size_t used;
        size_t capacity;
        char *mem;

        RubyStringBuffer(const RubyStringBuffer&);
        RubyStringBuffer& operator=(const RubyStringBuffer&);
};
