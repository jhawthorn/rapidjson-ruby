# frozen_string_literal: true

require_relative "lib/rapidjson/version"

Gem::Specification.new do |spec|
  spec.name = "rapidjson"
  spec.version = RapidJSON::VERSION
  spec.authors = ["John Hawthorn"]
  spec.email = ["john@hawthorn.email"]

  spec.summary = "Fast JSON encoder/decoder based using RapidJSON"
  spec.description = spec.summary
  spec.homepage = "https://github.com/jhawthorn/rapidjson"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    [
      Dir["ext/rapidjson/*.{hh,cc}"],
      Dir["ext/rapidjson/rapidjson/include/**/*.h"],
      Dir["lib/**/*.rb"],
      "CODE_OF_CONDUCT.md",
      "LICENSE.txt",
      "README.md",
      "Rakefile",
    ].flatten
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/rapidjson/extconf.rb"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
