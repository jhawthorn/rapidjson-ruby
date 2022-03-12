#ifndef RAPIDJSON_H
#define RAPIDJSON_H 1

#include "ruby.h"
#include "ruby/encoding.h"

#ifdef __SSE2__
#define RAPIDJSON_SSE2
#endif

/* fixme: compilation fails? */
#if 0
#ifdef __SSE4_2__
#define RAPIDJSON_SSE42
#endif
#endif

#include "rapidjson/rapidjson.h"

#endif /* RAPIDJSON_H */
