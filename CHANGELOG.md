# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-19

### Added

- Ruby wrapper for the `summarize` CLI tool
- `Summarize.call` for summarizing URLs and file paths
- `Summarize.from_text` for summarizing text content
- `Summarize.extract` for content extraction without LLM summarization
- Streaming support via block syntax
- Global configuration with `Summarize.configure`
- Support for all `summarize` CLI options including model, length, language, format, video mode, slides, and more
- `Summarize::Result` object with accessors for summary, extracted content, LLM metadata, and token metrics
- Custom error hierarchy: `BinaryNotFoundError`, `TimeoutError`, `CommandError`, etc.
- Environment variable passthrough for API keys
- Automatic binary detection
