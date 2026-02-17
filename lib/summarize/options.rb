# frozen_string_literal: true

module Summarize
  class Options
    LENGTHS = %i[short medium long xl xxl s m l].freeze
    VIDEO_MODES = %i[auto transcript understand].freeze
    FORMATS = %i[text md].freeze
    MARKDOWN_MODES = %i[off auto llm readability].freeze
    METRICS_MODES = %i[off on detailed].freeze

    OPTION_MAP = {
      model: "--model",
      length: "--length",
      language: "--lang",
      timeout: "--timeout",
      retries: "--retries",
      prompt: "--prompt",
      prompt_file: "--prompt-file",
      format: "--format",
      video_mode: "--video-mode",
      markdown_mode: "--markdown-mode",
      max_output_tokens: "--max-output-tokens",
      max_extract_characters: "--max-extract-characters",
      youtube: "--youtube",
      transcriber: "--transcriber",
      firecrawl: "--firecrawl",
      preprocess: "--preprocess",
      theme: "--theme",
      metrics: "--metrics"
    }.freeze

    BOOLEAN_FLAGS = {
      force_summary: "--force-summary",
      timestamps: "--timestamps",
      no_cache: "--no-cache",
      no_media_cache: "--no-media-cache",
      verbose: "--verbose",
      no_color: "--no-color",
      plain: "--plain"
    }.freeze

    def initialize(opts = {})
      @opts = opts
    end

    def to_args
      args = []

      OPTION_MAP.each do |key, flag|
        value = @opts[key]
        next if value.nil?

        args << flag << value.to_s
      end

      BOOLEAN_FLAGS.each do |key, flag|
        args << flag if @opts[key]
      end

      args
    end
  end
end
