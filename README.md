# summarize-ruby

Ruby wrapper for the [`summarize`](https://github.com/steipete/summarize) CLI tool. Summarize web pages, files, videos, and text using LLMs from OpenAI, Anthropic, Google, xAI, and more.

## Installation

First, install the `summarize` CLI:

```bash
npm i -g @steipete/summarize
```

Then add the gem to your Gemfile:

```ruby
gem "summarize-ruby"
```

Or install directly:

```bash
gem install summarize-ruby
```

## Usage

```ruby
require "summarize"

# Summarize a URL
result = Summarize.call("https://example.com/article")
puts result.summary

# Summarize a local file
result = Summarize.call("/path/to/document.pdf")

# Summarize text
result = Summarize.from_text("Long article text here...")

# Extract content without summarization
result = Summarize.extract("https://example.com", format: :md)
puts result.content
```

### Options

Pass any option as a keyword argument:

```ruby
result = Summarize.call("https://example.com",
  model: "anthropic/claude-sonnet-4-5",
  length: :short,
  language: "es",
  prompt: "Focus on technical details"
)
```

All supported options:

| Ruby option | CLI flag | Example values |
|---|---|---|
| `model` | `--model` | `"openai/gpt-5-mini"`, `"anthropic/claude-sonnet-4-5"`, `"auto"` |
| `length` | `--length` | `:short`, `:medium`, `:long`, `:xl`, `:xxl`, `5000` |
| `language` | `--lang` | `"en"`, `"es"`, `"de"`, `"auto"` |
| `prompt` | `--prompt` | `"Focus on key takeaways"` |
| `prompt_file` | `--prompt-file` | `"/path/to/prompt.txt"` |
| `format` | `--format` | `:text`, `:md` |
| `timeout` | `--timeout` | `"3m"`, `"30s"` |
| `retries` | `--retries` | `2` |
| `cli` | `--cli` | `"claude"`, `"gemini"`, `"codex"` |
| `video_mode` | `--video-mode` | `:auto`, `:transcript`, `:understand` |
| `markdown_mode` | `--markdown-mode` | `:off`, `:auto`, `:llm`, `:readability` |
| `max_output_tokens` | `--max-output-tokens` | `2000` |
| `max_extract_characters` | `--max-extract-characters` | `10000` |
| `youtube` | `--youtube` | `"auto"`, `"web"`, `"yt-dlp"` |
| `transcriber` | `--transcriber` | `"auto"`, `"whisper"`, `"parakeet"` |
| `firecrawl` | `--firecrawl` | `"off"`, `"auto"`, `"always"` |
| `preprocess` | `--preprocess` | `"off"`, `"auto"`, `"always"` |
| `theme` | `--theme` | `"aurora"`, `"ember"`, `"moss"`, `"mono"` |
| `metrics` | `--metrics` | `"off"`, `"on"`, `"detailed"` |
| `slides_dir` | `--slides-dir` | `"./my-slides"` |
| `slides_max` | `--slides-max` | `10` |
| `slides_min_duration` | `--slides-min-duration` | `5` |
| `slides_scene_threshold` | `--slides-scene-threshold` | `0.5` |

Boolean flags (pass `true` to enable):

| Ruby option | CLI flag |
|---|---|
| `force_summary` | `--force-summary` |
| `timestamps` | `--timestamps` |
| `no_cache` | `--no-cache` |
| `no_media_cache` | `--no-media-cache` |
| `slides` | `--slides` |
| `slides_debug` | `--slides-debug` |
| `slides_ocr` | `--slides-ocr` |
| `verbose` | `--verbose` |
| `debug` | `--debug` |
| `no_color` | `--no-color` |
| `plain` | `--plain` |

### Streaming

Pass a block to stream output as it arrives:

```ruby
Summarize.call("https://example.com") do |chunk|
  print chunk
end
```

### Result object

The `Result` object provides structured access to the response:

```ruby
result = Summarize.call("https://example.com")

# Summary
result.summary       # => "## Key Points\n..."
result.success?      # => true

# Extracted content
result.title         # => "Article Title"
result.description   # => "Article description"
result.content       # => "Full extracted content..."
result.site_name     # => "Example"
result.media_type    # => "text/html"

# LLM info
result.model         # => "gpt-5-mini"
result.provider      # => "openai"

# Token usage
result.total_tokens      # => 1550
result.prompt_tokens     # => 1200
result.completion_tokens # => 350

# Raw JSON
result.to_h          # => { "summary" => "...", "extracted" => { ... }, ... }
```

### Configuration

Set global defaults:

```ruby
Summarize.configure do |c|
  c.default_model = "anthropic/claude-sonnet-4-5"
  c.default_length = :medium
  c.default_language = "en"
  c.timeout = "3m"
  c.retries = 2
  c.default_cli = "claude"

  # Pass API keys to the CLI process
  c.env = {
    "ANTHROPIC_API_KEY" => ENV["ANTHROPIC_API_KEY"],
    "OPENAI_API_KEY" => ENV["OPENAI_API_KEY"]
  }

  # Custom binary path (auto-detected by default)
  c.binary_path = "/usr/local/bin/summarize"
end
```

Per-call options override configuration defaults:

```ruby
Summarize.configure { |c| c.default_model = "anthropic/claude-sonnet-4-5" }

# This uses gpt-5-mini, not the configured default
result = Summarize.call("https://example.com", model: "openai/gpt-5-mini")
```

### Error handling

```ruby
begin
  result = Summarize.call("https://example.com")
rescue Summarize::BinaryNotFoundError
  # summarize CLI not installed
rescue Summarize::CommandError => e
  e.exit_code  # => 1
  e.stderr     # => "error message"
rescue Summarize::SummarizationError => e
  # JSON parsing failed
rescue Summarize::Error => e
  # catch-all for any summarize error
end
```

## Requirements

- Ruby >= 3.1
- [`summarize`](https://github.com/steipete/summarize) CLI (`npm i -g @steipete/summarize`)
- At least one LLM provider API key (OpenAI, Anthropic, Google, etc.)

## Development

```bash
bundle install
bundle exec rspec
```

## License

MIT
