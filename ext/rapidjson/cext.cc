#include "cext.hh"

VALUE rb_mRapidjson;

extern "C"
void
Init_rapidjson(void)
{
  rb_mRapidjson = rb_define_module("Rapidjson");
}
