# frozen_string_literal: true

module Summarize
  class Configuration
    attr_accessor :default_model, :default_length, :default_language,
                  :default_cli, :timeout, :retries, :env
    attr_writer :binary_path

    def initialize
      @binary_path = nil
      @default_model = "auto"
      @default_cli = nil
      @default_length = nil
      @default_language = nil
      @timeout = nil
      @retries = nil
      @env = {}
    end

    def binary_path
      @binary_path ||= find_binary
    end

    private

    def find_binary
      path = `which summarize 2>/dev/null`.strip
      return path unless path.empty?

      ["/usr/local/bin/summarize", "/opt/homebrew/bin/summarize"].find { |p| File.executable?(p) } || "summarize"
    end
  end
end
