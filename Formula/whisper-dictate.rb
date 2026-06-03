class WhisperDictate < Formula
  desc "Local push-to-talk dictation -- speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/releases/download/v0.3.31/whisper-dictate-linux-0.3.31.zip"
  sha256 "63e2466b07542fea424e740e6c6f5bf4bcc3a1415e00e0241d8e4372c852d391"
  license "MIT"

  depends_on "portaudio"
  depends_on "python@3.12"

  def install
    payload = Dir["whisper-dictate/*"]
    payload = Dir["*"] if payload.empty?
    libexec.install payload
    chmod 0755, libexec/"whisper-dictate"
    chmod 0755, libexec/"ubuntu26.04/setup.sh"

    py = Formula["python@3.12"].opt_bin/"python3.12"
    (bin/"whisper-dictate").write <<~SH
      #!/bin/bash
      export VOICEPI_BOOTSTRAP_PYTHON="#{py}"
      export VOICEPI_APP_ROOT="#{libexec}"
      export VOICEPI_SKIP_SYSCHECK=1
      exec "#{libexec}/whisper-dictate" "$@"
    SH
  end

  def caveats
    <<~EOS
      whisper-dictate builds a machine-local Python venv on first run
      (~/.venv-whisper-dictate) and downloads the selected STT model.

      Ubuntu 24.04/26.04 Wayland - one-time desktop setup:

        whisper-dictate setup-ubuntu

      Then start the desktop app:

        whisper-dictate ui

      Terminal dictation is also available:

        whisper-dictate run --key ctrl_r --lang da
    EOS
  end

  test do
    assert_path_exists libexec/"voice_pi.py"
    assert_path_exists libexec/"whisper-dictate"
    assert_path_exists libexec/"ubuntu26.04/setup.sh"
    assert_match version.to_s, shell_output("#{bin}/whisper-dictate --version")
  end
end
