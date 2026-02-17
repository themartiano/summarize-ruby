# frozen_string_literal: true

module Summarize
  class Result
    attr_reader :raw

    def initialize(json)
      @raw = json
    end

    def summary
      raw["summary"]
    end

    def title
      dig("extracted", "title")
    end

    def description
      dig("extracted", "description")
    end

    def site_name
      dig("extracted", "siteName")
    end

    def content
      dig("extracted", "content")
    end

    def content_length
      dig("extracted", "contentLength")
    end

    def media_type
      dig("extracted", "mediaType")
    end

    def source
      dig("extracted", "source")
    end

    def model
      dig("llm", "model")
    end

    def provider
      dig("llm", "provider")
    end

    def prompt
      raw["prompt"]
    end

    def metrics
      raw["metrics"]
    end

    def llm_metrics
      dig("metrics", "llm") || []
    end

    def total_tokens
      llm_metrics.sum { |m| m["totalTokens"] || 0 }
    end

    def prompt_tokens
      llm_metrics.sum { |m| m["promptTokens"] || 0 }
    end

    def completion_tokens
      llm_metrics.sum { |m| m["completionTokens"] || 0 }
    end

    def input_kind
      dig("input", "kind")
    end

    def slides
      raw["slides"]
    end

    def success?
      !summary.nil?
    end

    def extract_only?
      summary.nil? && !content.nil?
    end

    def to_h
      raw
    end

    private

    def dig(*keys)
      keys.reduce(raw) { |hash, key| hash.is_a?(Hash) ? hash[key] : nil }
    end
  end
end
