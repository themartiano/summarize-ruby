# frozen_string_literal: true

RSpec.describe Summarize::Result do
  let(:fixture_path) { File.join(__dir__, "..", "fixtures", "summary_response.json") }
  let(:json) { JSON.parse(File.read(fixture_path)) }
  let(:result) { described_class.new(json) }

  describe "summary accessors" do
    it "returns the summary" do
      expect(result.summary).to start_with("## Key Points")
    end

    it "returns success? true when summary present" do
      expect(result.success?).to be true
    end

    it "returns the prompt" do
      expect(result.prompt).to eq("Summarize the following content...")
    end
  end

  describe "extracted content accessors" do
    it "returns the title" do
      expect(result.title).to eq("Test Article")
    end

    it "returns the description" do
      expect(result.description).to eq("A test article for testing")
    end

    it "returns the site name" do
      expect(result.site_name).to eq("Example")
    end

    it "returns the content" do
      expect(result.content).to eq("This is the full extracted content of the article.")
    end

    it "returns content_length" do
      expect(result.content_length).to eq(50)
    end

    it "returns media_type" do
      expect(result.media_type).to eq("text/html")
    end

    it "returns source" do
      expect(result.source).to eq("readability")
    end
  end

  describe "LLM accessors" do
    it "returns model" do
      expect(result.model).to eq("gpt-5-mini")
    end

    it "returns provider" do
      expect(result.provider).to eq("openai")
    end
  end

  describe "metrics" do
    it "returns total tokens" do
      expect(result.total_tokens).to eq(1550)
    end

    it "returns prompt tokens" do
      expect(result.prompt_tokens).to eq(1200)
    end

    it "returns completion tokens" do
      expect(result.completion_tokens).to eq(350)
    end
  end

  describe "extract-only result" do
    let(:fixture_path) { File.join(__dir__, "..", "fixtures", "extract_response.json") }

    it "returns success? false when no summary" do
      expect(result.success?).to be false
    end

    it "returns extract_only? true" do
      expect(result.extract_only?).to be true
    end

    it "still has extracted content" do
      expect(result.content).to include("extracted markdown content")
    end
  end

  describe "#to_h" do
    it "returns the raw hash" do
      expect(result.to_h).to be_a(Hash)
      expect(result.to_h).to eq(json)
    end
  end
end
