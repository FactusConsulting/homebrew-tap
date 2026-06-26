class Certwatch < Formula
  desc "Agent-friendly CLI for monitoring SSL/TLS certificate expiry across hosts"
  homepage "https://github.com/FactusConsulting/certwatch"
  version "0.1.7"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.7/certwatch-osx-arm64.tar.gz"
      sha256 "c381c60d9f46dfe5fe5d9986101e0816fc6adcb79ad35db1ca5d7effd9fb793f"
    end
    on_intel do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.7/certwatch-osx-x64.tar.gz"
      sha256 "53b6daa75a38a3c1ea8aa87d9adec4618748d0c2add70ba95b17bd90771433bc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.7/certwatch-linux-arm64.tar.gz"
      sha256 "76d63ba171633558c6d9d152ca776a10ac55d6165382227ed0ec9474c821a957"
    end
    on_intel do
      url "https://github.com/FactusConsulting/certwatch/releases/download/v0.1.7/certwatch-linux-x64.tar.gz"
      sha256 "219b50de31ee8253ca7b9bd48407556cf1fe7e6fc0820bdfccade2e193a1e7a8"
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
