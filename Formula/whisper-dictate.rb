class WhisperDictate < Formula
  desc "Local push-to-talk dictation — speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "00612f68926e64bdd9008e6ff11fadea05f322e77c7d1c1eba48e50cededb316"
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

      Wayland (Ubuntu 24.04/26.04): global hotkeys work via evdev.
      One-time setup required:
        sudo usermod -aG input $USER   # add to input group
        # log out and back in
        whisper-dictate --paste --key shift_r+ctrl_r   # builds venv + downloads model

      The default hotkey is right Ctrl (ctrl_r). Chord keys are supported:
        whisper-dictate --paste --key shift_r+ctrl_r

      For --paste on Wayland install ydotool and wl-clipboard:
        sudo apt install ydotool wl-clipboard
      For --paste on X11 install xclip:
        sudo apt install xclip

      In terminal emulators (ghostty, gnome-terminal) pass --paste-key ctrl+shift+v
      as terminals use Ctrl+Shift+V for paste (not Ctrl+V).
    EOS
  end

  test do
    assert_path_exists libexec/"voice_pi.py"
    assert_path_exists libexec/"setup.sh"
    assert_match "whisper-dictate", File.read(libexec/"README.md")
  end
end
