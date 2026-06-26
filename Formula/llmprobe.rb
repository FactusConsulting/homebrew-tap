class Llmprobe < Formula
  desc "Agent-friendly CLI for probing OpenAI-compatible LLM endpoints"
  homepage "https://github.com/FactusConsulting/llmprobe"
  version "0.2.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.2/llmprobe-osx-arm64.tar.gz"
      sha256 "373c1a2be448029f10ad1e879048e8958d4eb8940477c155d433128043b17268"
    end
    on_intel do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.2/llmprobe-osx-x64.tar.gz"
      sha256 "e8c91f7906b8cc46ea6121aaab15d3d3ce4389b99a82847190729369bdc0a990"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.2/llmprobe-linux-arm64.tar.gz"
      sha256 "dd824c523aa30067a4f66d02c9975e1d072ecd30f6cb935a5d6cbeeaab1ebca1"
    end
    on_intel do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.2/llmprobe-linux-x64.tar.gz"
      sha256 "ce45560d53dd8de7aa739d0308adc96c88caf7bb5e0c0cb76acb256c70f4280c"
    end
  end

  def install
    bin.install "llmprobe"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/llmprobe --version")
    assert_match "guidance for AI agents", shell_output("#{bin}/llmprobe --help-ai")
  end
end
