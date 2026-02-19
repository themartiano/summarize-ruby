# frozen_string_literal: true

RSpec.describe Summarize::Options do
  describe "#to_args" do
    it "maps model option to --model flag" do
      args = described_class.new(model: "openai/gpt-5-mini").to_args
      expect(args).to eq(["--model", "openai/gpt-5-mini"])
    end

    it "maps length symbol to --length flag" do
      args = described_class.new(length: :short).to_args
      expect(args).to eq(["--length", "short"])
    end

    it "maps numeric length to --length flag" do
      args = described_class.new(length: 5000).to_args
      expect(args).to eq(["--length", "5000"])
    end

    it "maps language to --lang flag" do
      args = described_class.new(language: "es").to_args
      expect(args).to eq(["--lang", "es"])
    end

    it "maps timeout to --timeout flag" do
      args = described_class.new(timeout: "3m").to_args
      expect(args).to eq(["--timeout", "3m"])
    end

    it "maps prompt to --prompt flag" do
      args = described_class.new(prompt: "Focus on technical details").to_args
      expect(args).to eq(["--prompt", "Focus on technical details"])
    end

    it "maps video_mode to --video-mode flag" do
      args = described_class.new(video_mode: :transcript).to_args
      expect(args).to eq(["--video-mode", "transcript"])
    end

    it "maps format to --format flag" do
      args = described_class.new(format: :md).to_args
      expect(args).to eq(["--format", "md"])
    end

    it "maps boolean flags correctly" do
      args = described_class.new(force_summary: true, timestamps: true, no_cache: true).to_args
      expect(args).to include("--force-summary")
      expect(args).to include("--timestamps")
      expect(args).to include("--no-cache")
    end

    it "ignores nil values" do
      args = described_class.new(model: nil, length: nil).to_args
      expect(args).to be_empty
    end

    it "ignores false boolean flags" do
      args = described_class.new(force_summary: false, verbose: false).to_args
      expect(args).to be_empty
    end

    it "maps slides boolean flag" do
      args = described_class.new(slides: true).to_args
      expect(args).to eq(["--slides"])
    end

    it "maps slides_debug boolean flag" do
      args = described_class.new(slides_debug: true).to_args
      expect(args).to eq(["--slides-debug"])
    end

    it "maps slides_ocr boolean flag" do
      args = described_class.new(slides_ocr: true).to_args
      expect(args).to eq(["--slides-ocr"])
    end

    it "maps slides_dir to --slides-dir flag" do
      args = described_class.new(slides_dir: "./my-slides").to_args
      expect(args).to eq(["--slides-dir", "./my-slides"])
    end

    it "maps slides_max to --slides-max flag" do
      args = described_class.new(slides_max: 10).to_args
      expect(args).to eq(["--slides-max", "10"])
    end

    it "maps debug boolean flag" do
      args = described_class.new(debug: true).to_args
      expect(args).to eq(["--debug"])
    end

    it "maps cli to --cli flag" do
      args = described_class.new(cli: "claude").to_args
      expect(args).to eq(["--cli", "claude"])
    end

    it "combines multiple options" do
      args = described_class.new(
        model: "google/gemini-3-flash-preview",
        length: :medium,
        language: "de",
        no_cache: true
      ).to_args

      expect(args).to eq([
        "--model", "google/gemini-3-flash-preview",
        "--length", "medium",
        "--lang", "de",
        "--no-cache"
      ])
    end
  end
end
