# frozen_string_literal: true

require "open3"
require "json"
require "tempfile"

module Summarize
  class Client
    attr_reader :config

    def initialize(config = Summarize.configuration)
      @config = config
    end

    # Summarize a URL or file path.
    #
    #   client.call("https://example.com", length: :short, model: "openai/gpt-5-mini")
    #   client.call("/path/to/file.pdf", language: "es")
    #
    # With a block, streams chunks as they arrive:
    #
    #   client.call("https://example.com") { |chunk| print chunk }
    #
    def call(input, **opts, &block)
      if block_given?
        stream(input, **opts, &block)
      else
        run_json(input, **opts)
      end
    end

    # Summarize text content by writing to a temp file.
    #
    #   client.from_text("Long article text...", length: :medium)
    #
    def from_text(text, **opts, &block)
      with_temp_file(text) do |path|
        if block_given?
          stream(path, **opts, &block)
        else
          run_json(path, **opts)
        end
      end
    end

    # Extract content without LLM summarization.
    #
    #   result = client.extract("https://example.com", format: :md)
    #   result.content  # => extracted markdown
    #
    def extract(input, **opts)
      run_json(input, extract: true, **opts)
    end

    private

    def run_json(input, extract: false, **opts)
      args = build_args(input, extract: extract, stream: false, json: true, **opts)

      stdout, stderr, status = execute(args)

      handle_error!(status, stderr) unless status.success?

      parsed = JSON.parse(stdout)
      Result.new(parsed)
    rescue JSON::ParserError => e
      raise SummarizationError, "Failed to parse JSON output: #{e.message}\nOutput: #{stdout&.slice(0, 500)}"
    end

    def stream(input, **opts, &block)
      validate_binary!
      validate_version!
      args = build_args(input, stream: true, json: false, **opts)

      full_output = +""

      Open3.popen3(command_env, *args) do |stdin, stdout, stderr, wait_thread|
        stdin.close

        stdout.each_line do |line|
          full_output << line
          block.call(line)
        end

        status = wait_thread.value
        handle_error!(status, stderr.read) unless status.success?
      end

      full_output
    end

    def with_temp_file(text)
      file = Tempfile.new(["summarize-input", ".txt"])
      file.write(text)
      file.flush
      file.close
      yield file.path
    ensure
      file&.unlink
    end

    def build_args(input, extract: false, stream: nil, json: false, **opts)
      merged = apply_defaults(opts)

      args = [config.binary_path]
      args << input

      args << "--json" if json
      args << "--stream" << "off" if stream == false
      args << "--stream" << "on" if stream == true
      args << "--extract" if extract
      args << "--metrics" << "on" if json

      args.concat(Options.new(merged).to_args)

      args
    end

    def apply_defaults(opts)
      defaults = {}
      defaults[:model] = config.default_model if config.default_model && config.default_model != "auto"
      defaults[:cli] = config.default_cli if config.default_cli
      defaults[:length] = config.default_length if config.default_length
      defaults[:language] = config.default_language if config.default_language
      defaults[:timeout] = config.timeout if config.timeout
      defaults[:retries] = config.retries if config.retries

      defaults.merge(opts)
    end

    def command_env
      env = {}
      config.env.each { |k, v| env[k.to_s] = v.to_s }
      env
    end

    def execute(args)
      validate_binary!
      validate_version!

      Open3.capture3(command_env, *args)
    end

    def validate_binary!
      path = config.binary_path
      return if path == "summarize" # rely on PATH
      return if File.executable?(path)

      raise BinaryNotFoundError, path
    end

    def validate_version!
      return if config.skip_version_check

      installed = config.cli_version
      return unless installed # can't detect — skip gracefully

      required = Summarize::MINIMUM_CLI_VERSION
      if Gem::Version.new(installed) < Gem::Version.new(required)
        raise VersionMismatchError.new(installed, required)
      end
    end

    def handle_error!(status, stderr)
      case status.exitstatus
      when 130
        raise Error, "Interrupted (SIGINT)"
      when 143
        raise Error, "Terminated (SIGTERM)"
      else
        raise CommandError.new(status.exitstatus, stderr&.strip || "")
      end
    end
  end
end
