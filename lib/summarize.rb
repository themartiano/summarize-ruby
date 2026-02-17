# frozen_string_literal: true

require_relative "summarize/version"
require_relative "summarize/configuration"
require_relative "summarize/errors"
require_relative "summarize/options"
require_relative "summarize/result"
require_relative "summarize/client"

module Summarize
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    # Convenience method: summarize a URL or file path.
    #
    #   Summarize.call("https://example.com", length: :short)
    #
    def call(input, **opts, &block)
      Client.new.call(input, **opts, &block)
    end

    # Convenience method: summarize text content.
    #
    #   Summarize.from_text("Long text...", length: :medium)
    #
    def from_text(text, **opts, &block)
      Client.new.from_text(text, **opts, &block)
    end

    # Convenience method: extract content without summarization.
    #
    #   Summarize.extract("https://example.com", format: :md)
    #
    def extract(input, **opts)
      Client.new.extract(input, **opts)
    end
  end
end
