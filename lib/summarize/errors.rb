# frozen_string_literal: true

module Summarize
  class Error < StandardError; end

  class BinaryNotFoundError < Error
    def initialize(path)
      super("summarize binary not found at '#{path}'. Install via: npm i -g @steipete/summarize")
    end
  end

  class TimeoutError < Error
    def initialize(timeout)
      super("summarize timed out after #{timeout}")
    end
  end

  class ExtractionError < Error; end

  class SummarizationError < Error; end

  class CommandError < Error
    attr_reader :exit_code, :stderr

    def initialize(exit_code, stderr)
      @exit_code = exit_code
      @stderr = stderr
      super("summarize exited with code #{exit_code}: #{stderr}")
    end
  end
end
