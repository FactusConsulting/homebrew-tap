class Llmprobe < Formula
  desc "Agent-friendly CLI for probing OpenAI-compatible LLM endpoints"
  homepage "https://github.com/FactusConsulting/llmprobe"
  version "0.2.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.3/llmprobe-osx-arm64.tar.gz"
      sha256 "62072f6624a038e82bf6d2b59fea2bdc040a9357ded87d089ce0b3b6a05b789c"
    end
    on_intel do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.3/llmprobe-osx-x64.tar.gz"
      sha256 "26cf5f273840288deca59f2f16c76ed285884e03be063ae9c9de70471e4a465d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.3/llmprobe-linux-arm64.tar.gz"
      sha256 "1aa8a4994109069b86f19e3e01b5e149690eefabf6704e21d8bf8b185e288b9c"
    end
    on_intel do
      url "https://github.com/FactusConsulting/llmprobe/releases/download/v0.2.3/llmprobe-linux-x64.tar.gz"
      sha256 "40e1e553ec1a8e88cf280dcd545d6ab24f4835bc2e29fc5f2891334b72df5058"
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
