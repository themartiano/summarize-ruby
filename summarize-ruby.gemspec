# frozen_string_literal: true

require_relative "lib/summarize/version"

Gem::Specification.new do |spec|
  spec.name = "summarize-ruby"
  spec.version = Summarize::VERSION
  spec.authors = ["Martiano"]
  spec.email = ["hello@martiano.com"]

  spec.summary = "Ruby wrapper for the summarize CLI"
  spec.description = "A Ruby gem that wraps the summarize CLI tool, providing a clean Ruby API " \
                     "for summarizing URLs, files, and text using various LLM providers."
  spec.homepage = "https://github.com/martiano/summarize-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/summarize-ruby"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "json", ">= 2.0"
end
