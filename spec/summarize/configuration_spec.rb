# frozen_string_literal: true

RSpec.describe Summarize::Configuration do
  describe "defaults" do
    it "sets default_model to auto" do
      expect(subject.default_model).to eq("auto")
    end

    it "has nil default_length" do
      expect(subject.default_length).to be_nil
    end

    it "has nil default_language" do
      expect(subject.default_language).to be_nil
    end

    it "has empty env" do
      expect(subject.env).to eq({})
    end
  end

  describe "Summarize.configure" do
    it "yields the configuration" do
      Summarize.configure do |c|
        c.default_model = "openai/gpt-5-mini"
        c.default_length = :medium
        c.default_language = "en"
        c.timeout = "3m"
        c.retries = 2
        c.env = { "OPENAI_API_KEY" => "sk-test" }
      end

      config = Summarize.configuration
      expect(config.default_model).to eq("openai/gpt-5-mini")
      expect(config.default_length).to eq(:medium)
      expect(config.default_language).to eq("en")
      expect(config.timeout).to eq("3m")
      expect(config.retries).to eq(2)
      expect(config.env).to eq({ "OPENAI_API_KEY" => "sk-test" })
    end
  end

  describe "Summarize.reset_configuration!" do
    it "resets to defaults" do
      Summarize.configure { |c| c.default_model = "custom" }
      Summarize.reset_configuration!
      expect(Summarize.configuration.default_model).to eq("auto")
    end
  end
end
