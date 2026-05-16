class WhisperDictate < Formula
  desc "Local push-to-talk dictation — speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "e55855a4ece37abcdbf8f59a710ed3844bb31520c5d63679300a94af26766031"
  license "MIT"

  depends_on "portaudio"
  depends_on "python@3.12"

  def install
    libexec.install "voice_pi.py", "requirements-cpu.txt", "setup.sh", "README.md", "LICENSE"
    chmod 0755, libexec/"setup.sh"
    py = Formula["python@3.12"].opt_bin/"python3.12"
    (bin/"whisper-dictate").write <<~SH
      #!/bin/bash
      # Homebrew provides python@3.12 + portaudio via formula deps, so
      # use that interpreter and skip setup.sh's apt prerequisite checks.
      export VOICEPI_PYTHON="#{py}"
      export VOICEPI_SKIP_SYSCHECK=1
      exec "#{libexec}/setup.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      whisper-dictate builds a machine-local Python venv on first run
      (~/.venv-whisper-dictate) and downloads the Whisper model
      (~1.5 GB). It runs on CPU here (no NVIDIA acceleration via brew).

      Linux input limitation: global push-to-talk and synthetic typing
      use pynput, which is X11-only. On GNOME/Wayland the compositor
      blocks both — log in on an Xorg session, or run:
          whisper-dictate --no-type
      For --paste install a clipboard tool: wl-clipboard (Wayland) or
      xclip (X11).
    EOS
  end

  test do
    assert_path_exists libexec/"voice_pi.py"
    assert_path_exists libexec/"setup.sh"
    assert_match "whisper-dictate", File.read(libexec/"README.md")
  end
end
