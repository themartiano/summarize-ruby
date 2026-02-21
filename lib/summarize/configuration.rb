# frozen_string_literal: true

module Summarize
  class Configuration
    attr_accessor :default_model, :default_length, :default_language,
                  :default_cli, :timeout, :retries, :env,
                  :skip_version_check
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
      @skip_version_check = false
      @cli_version = nil
    end

    def binary_path
      @binary_path ||= find_binary
    end

    def cli_version
      @cli_version ||= detect_cli_version
    end

    def reset_cli_version!
      @cli_version = nil
    end

    private

    def detect_cli_version
      output = `#{binary_path} --version 2>/dev/null`.strip
      return nil if output.empty?

      # Extract semver part — CLI may output "0.11.1 (ae52818b)"
      output[/\d+\.\d+\.\d+/]
    end

    def find_binary
      path = `which summarize 2>/dev/null`.strip
      return path unless path.empty?

      ["/usr/local/bin/summarize", "/opt/homebrew/bin/summarize"].find { |p| File.executable?(p) } || "summarize"
    end
  end
end
