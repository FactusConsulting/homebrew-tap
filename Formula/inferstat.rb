class Inferstat < Formula
  desc "Agent-friendly CLI for inspecting llama.cpp/vLLM/Ollama inference servers"
  homepage "https://github.com/FactusConsulting/inferstat"
  version "0.1.9"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.9/inferstat-osx-arm64.tar.gz"
      sha256 "3c5d41bd0f27a620bb1bed8bde652122741fdd8812dfd61a8b280d309ae1ade2"
    end
    on_intel do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.9/inferstat-osx-x64.tar.gz"
      sha256 "eb88a3733d4b83bf577bcf198193f8f697d9ed352fabecf18078d30780745fe7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.9/inferstat-linux-arm64.tar.gz"
      sha256 "2c28b716fe7259731a09b55098e15f3789536861b1b3d853b04865a7cade00aa"
    end
    on_intel do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.9/inferstat-linux-x64.tar.gz"
      sha256 "b6112aa126ca0549d5f9a676692a760f2412cf3ccf49af67cb970aaa8a7833dd"
    end
  end

  def install
    bin.install "inferstat"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/inferstat --version")
    assert_match "guidance for AI agents", shell_output("#{bin}/inferstat --help-ai")
  end
end
