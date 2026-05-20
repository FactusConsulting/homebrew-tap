class WhisperDictate < Formula
  desc "Local push-to-talk dictation — speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/archive/refs/tags/v0.2.31.tar.gz"
  sha256 "45fef114e6df6c5aa9be3468230ce239834824598005ef9f2179ec193f5c2886"
  license "MIT"

  depends_on "portaudio"
  depends_on "python@3.12"

  def install
    libexec.install "voice_pi.py", "requirements-cpu.txt", "setup.sh", "README.md", "LICENSE"
    libexec.install Dir["vp_*.py"]   # split modules imported by voice_pi.py (empty pre-0.2.28)
    libexec.install "ubuntu26.04"
    chmod 0755, libexec/"setup.sh"
    chmod 0755, libexec/"ubuntu26.04/setup.sh"
    py = Formula["python@3.12"].opt_bin/"python3.12"
    (bin/"whisper-dictate").write <<~SH
      #!/bin/bash
      export VOICEPI_PYTHON="#{py}"
      export VOICEPI_SKIP_SYSCHECK=1
      exec "#{libexec}/setup.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      whisper-dictate builds a machine-local Python venv on first run
      (~/.venv-whisper-dictate) and downloads the Whisper model (~1.5 GB).
      It runs on CPU (no NVIDIA acceleration via brew).

      Ubuntu 26.04 / Wayland — one-time system setup:

        bash "$(brew --prefix whisper-dictate)/libexec/ubuntu26.04/setup.sh"

      This installs ydotool, sets up the input group and udev rules,
      starts the ydotoold daemon, and creates a GNOME autostart entry.
      Log out and back in afterwards, then:

        whisper-dictate --key shift_r+ctrl_r --lang da
    EOS
  end

  test do
    assert_path_exists libexec/"voice_pi.py"
    assert_path_exists libexec/"ubuntu26.04/setup.sh"
    assert_match "whisper-dictate", File.read(libexec/"README.md")
  end
end
