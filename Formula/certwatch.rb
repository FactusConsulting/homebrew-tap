class Certwatch < Formula
  desc "Agent-friendly CLI for monitoring SSL/TLS certificate expiry across hosts"
  homepage "https://github.com/FactusConsulting/certwatch"
  version "0.1.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.8/certwatch-osx-arm64.tar.gz"
      sha256 "4db97e0bd6eca5f2c14b8517135f63d4b2468ed471aad56982fbf739118a0f6d"
    end
    on_intel do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.8/certwatch-osx-x64.tar.gz"
      sha256 "f560f422cf293f356550e5df606d70c25619bb2b2cf7509e788d4a21e57c21fc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.8/certwatch-linux-arm64.tar.gz"
      sha256 "0e96fb391b612e2516b4abd027cb7e64227168972c10d8861e9c307c28d58686"
    end
    on_intel do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.8/certwatch-linux-x64.tar.gz"
      sha256 "cded1e32e3a0a83ea120aae1aa503b468b5ba61997ca725bb922593e5553899e"
    end
  end

  def install
    bin.install "certwatch"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/certwatch --version")
    assert_match "guidance for AI agents", shell_output("#{bin}/certwatch --help-ai")
  end
end
