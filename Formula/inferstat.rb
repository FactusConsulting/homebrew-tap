class Inferstat < Formula
  desc "Agent-friendly CLI for inspecting llama.cpp/vLLM/Ollama inference servers"
  homepage "https://github.com/FactusConsulting/inferstat"
  version "0.1.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.8/inferstat-osx-arm64.tar.gz"
      sha256 "4c5773f4038141e64d9673974775c002a872d2a86cf008e46eab297317b67b0c"
    end
    on_intel do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.8/inferstat-osx-x64.tar.gz"
      sha256 "930d86ddf38183b8d8a2394b297527c884908ac8decf19a1d8ca976d1f294b13"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.8/inferstat-linux-arm64.tar.gz"
      sha256 "d22d1f34a9845efa0db1b82a7c24886e18ce78bd4aa73cd2bff6b8323cb0e011"
    end
    on_intel do
      url "https://github.com/FactusConsulting/inferstat/releases/download/v0.1.8/inferstat-linux-x64.tar.gz"
      sha256 "66f15f137b54b2e94df53cf429ac507202a487a779a59d01f84289a87303db1f"
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
