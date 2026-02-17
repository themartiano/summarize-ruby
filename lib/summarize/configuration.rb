# frozen_string_literal: true

module Summarize
  class Configuration
    attr_accessor :binary_path, :default_model, :default_length, :default_language,
                  :timeout, :retries, :env

    def initialize
      @binary_path = find_binary
      @default_model = "auto"
      @default_length = nil
      @default_language = nil
      @timeout = nil
      @retries = nil
      @env = {}
    end

    private

    def find_binary
      # Check common locations
      paths = [
        `which summarize 2>/dev/null`.strip,
        "/usr/local/bin/summarize",
        "/opt/homebrew/bin/summarize"
      ]

      found = paths.find { |p| !p.empty? && File.executable?(p) }
      found || "summarize"
    end
  end
end
