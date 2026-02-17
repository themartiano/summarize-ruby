# frozen_string_literal: true

RSpec.describe Summarize::Client do
  let(:client) { described_class.new }
  let(:fixture_path) { File.join(__dir__, "..", "fixtures", "summary_response.json") }
  let(:fixture_json) { File.read(fixture_path) }
  let(:success_status) { instance_double(Process::Status, success?: true, exitstatus: 0) }
  let(:failure_status) { instance_double(Process::Status, success?: false, exitstatus: 1) }

  before do
    Summarize.configure do |c|
      c.binary_path = "/usr/local/bin/summarize"
    end
    allow(File).to receive(:executable?).and_call_original
    allow(File).to receive(:executable?).with("/usr/local/bin/summarize").and_return(true)
  end

  describe "#call" do
    it "calls summarize CLI with --json and --stream off" do
      expect(Open3).to receive(:capture3).with(
        {},
        "/usr/local/bin/summarize", "https://example.com",
        "--json", "--stream", "off", "--metrics", "on"
      ).and_return([fixture_json, "", success_status])

      result = client.call("https://example.com")
      expect(result).to be_a(Summarize::Result)
      expect(result.summary).to include("Key Points")
    end

    it "passes options as CLI flags" do
      expect(Open3).to receive(:capture3).with(
        {},
        "/usr/local/bin/summarize", "https://example.com",
        "--json", "--stream", "off", "--metrics", "on",
        "--model", "openai/gpt-5-mini",
        "--length", "short",
        "--lang", "es"
      ).and_return([fixture_json, "", success_status])

      client.call("https://example.com",
        model: "openai/gpt-5-mini",
        length: :short,
        language: "es"
      )
    end

    it "raises CommandError on non-zero exit" do
      expect(Open3).to receive(:capture3).and_return(["", "Something went wrong", failure_status])

      expect {
        client.call("https://example.com")
      }.to raise_error(Summarize::CommandError) { |e|
        expect(e.exit_code).to eq(1)
        expect(e.stderr).to eq("Something went wrong")
      }
    end

    it "raises SummarizationError on invalid JSON" do
      expect(Open3).to receive(:capture3).and_return(["not json", "", success_status])

      expect {
        client.call("https://example.com")
      }.to raise_error(Summarize::SummarizationError, /Failed to parse JSON/)
    end
  end

  describe "#from_text" do
    it "writes text to a temp file and passes the path" do
      expect(Open3).to receive(:capture3) do |env, binary, path, *rest|
        expect(env).to eq({})
        expect(binary).to eq("/usr/local/bin/summarize")
        expect(File.read(path)).to eq("Hello world, this is some text")
        expect(rest).to include("--json")
        [fixture_json, "", success_status]
      end

      result = client.from_text("Hello world, this is some text")
      expect(result.summary).to include("Key Points")
    end

    it "cleans up the temp file after use" do
      temp_path = nil
      expect(Open3).to receive(:capture3) do |_env, _binary, path, *_rest|
        temp_path = path
        expect(File.exist?(path)).to be true
        [fixture_json, "", success_status]
      end

      client.from_text("some text")
      expect(File.exist?(temp_path)).to be false
    end
  end

  describe "#extract" do
    let(:extract_fixture_path) { File.join(__dir__, "..", "fixtures", "extract_response.json") }
    let(:extract_json) { File.read(extract_fixture_path) }

    it "passes --extract flag" do
      expect(Open3).to receive(:capture3).with(
        {},
        "/usr/local/bin/summarize", "https://example.com",
        "--json", "--stream", "off", "--extract", "--metrics", "on",
        "--format", "md"
      ).and_return([extract_json, "", success_status])

      result = client.extract("https://example.com", format: :md)
      expect(result.extract_only?).to be true
      expect(result.content).to include("extracted markdown")
    end
  end

  describe "#call with streaming block" do
    it "yields chunks line by line" do
      stdin = instance_double(IO, close: nil)
      stdout = StringIO.new("Line 1\nLine 2\nLine 3\n")
      stderr = instance_double(IO, read: "")
      wait_thread = instance_double(Thread, value: success_status)

      expect(Open3).to receive(:popen3).and_yield(stdin, stdout, stderr, wait_thread)

      chunks = []
      client.call("https://example.com") { |chunk| chunks << chunk }

      expect(chunks).to eq(["Line 1\n", "Line 2\n", "Line 3\n"])
    end
  end

  describe "configuration" do
    it "applies default model from config" do
      Summarize.configure do |c|
        c.binary_path = "/usr/local/bin/summarize"
        c.default_model = "anthropic/claude-sonnet-4-5"
      end
      allow(File).to receive(:executable?).with("/usr/local/bin/summarize").and_return(true)
      client = described_class.new

      expect(Open3).to receive(:capture3).with(
        {},
        "/usr/local/bin/summarize", "https://example.com",
        "--json", "--stream", "off", "--metrics", "on",
        "--model", "anthropic/claude-sonnet-4-5"
      ).and_return([fixture_json, "", success_status])

      client.call("https://example.com")
    end

    it "option overrides default" do
      Summarize.configure do |c|
        c.binary_path = "/usr/local/bin/summarize"
        c.default_model = "anthropic/claude-sonnet-4-5"
      end
      allow(File).to receive(:executable?).with("/usr/local/bin/summarize").and_return(true)
      client = described_class.new

      expect(Open3).to receive(:capture3).with(
        {},
        "/usr/local/bin/summarize", "https://example.com",
        "--json", "--stream", "off", "--metrics", "on",
        "--model", "openai/gpt-5-mini"
      ).and_return([fixture_json, "", success_status])

      client.call("https://example.com", model: "openai/gpt-5-mini")
    end

    it "passes environment variables" do
      Summarize.configure do |c|
        c.binary_path = "/usr/local/bin/summarize"
        c.env = { "OPENAI_API_KEY" => "sk-test123" }
      end
      allow(File).to receive(:executable?).with("/usr/local/bin/summarize").and_return(true)
      client = described_class.new

      expect(Open3).to receive(:capture3).with(
        { "OPENAI_API_KEY" => "sk-test123" },
        "/usr/local/bin/summarize", "https://example.com",
        "--json", "--stream", "off", "--metrics", "on"
      ).and_return([fixture_json, "", success_status])

      client.call("https://example.com")
    end
  end

  describe "error handling" do
    it "raises specific error on SIGINT (exit 130)" do
      sigint_status = instance_double(Process::Status, success?: false, exitstatus: 130)
      expect(Open3).to receive(:capture3).and_return(["", "", sigint_status])

      expect {
        client.call("https://example.com")
      }.to raise_error(Summarize::Error, /Interrupted/)
    end

    it "raises BinaryNotFoundError for non-existent custom path" do
      Summarize.configure { |c| c.binary_path = "/nonexistent/summarize" }
      allow(File).to receive(:executable?).with("/nonexistent/summarize").and_return(false)
      client = described_class.new

      expect {
        client.call("https://example.com")
      }.to raise_error(Summarize::BinaryNotFoundError)
    end
  end
end
