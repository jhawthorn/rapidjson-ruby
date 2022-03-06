#include "rapidjson.h"

VALUE rb_mRapidjson;

void
Init_rapidjson(void)
{
  rb_mRapidjson = rb_define_module("Rapidjson");
}
