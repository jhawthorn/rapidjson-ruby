# RapidJSON

(Maybe) Ruby's fastest JSON library! Built using the [RapidJSON C++ library](https://rapidjson.org/)

ActiveSupport integration, `json` gem emulation, and no monkey patches.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rapidjson'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rapidjson

## Usage

``` ruby
RapidJSON.parse <<JSON
{
  "foo":"bar"
}
JSON
# => {"foo" => "bar"}
```

``` ruby
RapidJSON.encode(json_string)
# => '{"foo":"bar"}'
```

``` ruby
RapidJSON.pretty_encode(json_string)
# =>
# {
#    "foo": "bar"
# }
```

By default the encoder is "strict" and will raise an exception.

## ActiveSupport

RapidJSON provides a drop-in replacement ActiveSupport encoder, with very good compatibility.
Add the following to an initializer to opt-in.

```ruby
# config/initializers/rapidjson.rb

ActiveSupport::JSON::Encoding.json_encoder = RapidJSON::ActiveSupportEncoder
```

This makes `model.to_json` ~15x faster, and `nested_hash.to_json` ~27x faster (compared using Rails 7.0)

## JSON gem compatibility

Contrary to some other JSON libraries, `RapidJSON` doesn't provide a monkey patch to entirely replace the stdlib JSON gem.

However it does provide a module that behave like the stdlib JSON gem and that can be used to monkey patch existing code.

```ruby
module SomeLibrary
  def do_stuff(payload)
    JSON.parse(payload)
  end
end
```

```ruby
SomeLibrary::JSON = RapidJSON::JSONGem
```

Note that this module only use `RapidJSON` when it's certain it is safe to do so. If the JSON gem is called with
some options that `RapidJSON` doesn't support, it automatically fallbacks to calling the JSON gem.

## Advanced usage

By default RapidJSON will only encode "JSON-ready" types: `Hash`, `Array`, `Integer`, `Float`, `String`, `Symbol`, `true`, `false`, and `nil`.

RapidJSON::Coder can be initialized with a block which allows the behaviour to be customized. This is how the ActiveSupport encoder and JSON compatibility above are implemented! Just using Ruby :heart:.

```ruby
RapidJSON::Coder.new do |object, is_key|
  object.to_s # Convert any unknown object to string
end
```

The block is called only for unrecognized types. The return value is expected to be a "JSON ready" type which will then be encoded.

One additional special type is `RapidJSON::Fragment`, which is interpreted as an existing JSON-encoded string. This can be used to efficiently embed an existing JSON document, or to provide compatibility.

## Performance

Your current JSON parser/encoder is probably fine.

Unless there's good reason, it's probably best sticking with the standard `json` gem, which ships with Ruby. It become much faster in version 2.3, so try it again if you haven't recently!

However this library has a few performance advantages:

* JSON parsing
  * Performance is achieved mostly through using RapidJSON one of the fastest open source JSON parsing libraries. It supports SIMD (SSE2, SSE4.2, NEON), avoids allocated memory, and has been honed to be if not the fastest library (that honour likely going to simdjson), the library to beat for JSON performance.
* Object allocation
  * Wherever possible we avoid allocating objects. When generating JSON, RapidJSON will write the emitted JSON directly into the buffer of a Ruby string. (This is an optimization most Ruby JSON libraries will have)
  * When parsing JSON we parse directly form the source string with a single copy
  * When building a Hash for a JSON object, we use `fstrings` (dedup'd and frozen strings) as the key
  * Whenever possible we build Ruby objects from C types (int, char \*, double) rather than constructing intermediate Ruby string objects.

Many of these optimization can be found in all popular Ruby JSON libraries

```
== Encoding canada.json (2090234 bytes)
                yajl     13.957  (± 0.0%) i/s -     70.000  in   5.015358s
                json     13.912  (± 0.0%) i/s -     70.000  in   5.032247s
                  oj     20.821  (± 0.0%) i/s -    106.000  in   5.090981s
           rapidjson     84.110  (± 2.4%) i/s -    424.000  in   5.042792s
```

```
== Parsing canada.json (2251051 bytes)
                yajl     35.510  (± 2.8%) i/s -    180.000  in   5.070803s
                json     22.105  (± 0.0%) i/s -    112.000  in   5.067063s
                  oj     15.163  (± 6.6%) i/s -     76.000  in   5.042864s
           rapidjson    148.263  (± 2.0%) i/s -    742.000  in   5.006370s
```
Notes: oj seems unusually bad at this test, and is usually faster than yajl and
json, and comparable to rapidjson.

Other libraries may include modes to avoid constructing all objects. Currently
RapidJSON only focuses on the patterns and APIs users are likely to actually
use.

## Why another JSON library

I spent a week working on YAJL/yajl-ruby, and though I really liked the library, it hasn't kept up with the performance of the modern JSON libraries, specifically simdjson (C++), serde-json (Rust), and RapidJSON (C++). I was interested in how those libraries would integrate into Ruby. Of these, RapidJSON was the simplest fit for a Ruby extension. It's in C++ (clean Rust/Ruby bindings is unfortunately a work in progress), fast, uses SIMD instructions, supports encoding and decoding, and has a nice API to work with.

However, if you're happy with your current Ruby JSON library (including `json`) you should keep using it. They're all very good.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jhawthorn/rapidjson. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jhawthorn/rapidjson/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RapidJSON project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/jhawthorn/rapidjson/blob/main/CODE_OF_CONDUCT.md).
