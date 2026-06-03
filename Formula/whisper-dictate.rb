class WhisperDictate < Formula
  desc "Local push-to-talk dictation -- speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/releases/download/v0.3.32/whisper-dictate-linux-0.3.32.zip"
  sha256 "f092003d171b810be6552225d7b07637227bd788d7a6ea8310d661081b30b255"
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

  def post_install
    return unless OS.linux?

    home = ENV["HOME"]
    return if home.nil? || home.empty?

    exe = bin/"whisper-dictate"
    repair_linux_desktop_entry(
      Pathname.new(home)/".local/share/applications/whisper-dictate.desktop",
      exe,
      false,
    )
    repair_linux_desktop_entry(
      Pathname.new(home)/".config/autostart/whisper-dictate.desktop",
      exe,
      true,
    )
  end

  def repair_linux_desktop_entry(path, exe, autostart)
    return unless path.exist?

    raw = path.read
    return unless raw.include?("whisper-dictate")

    path.dirname.mkpath
    path.write <<~DESKTOP
      [Desktop Entry]
      Name=Whisper Dictate
      Comment=Push-to-talk dictation settings and runtime control
      Exec=#{exe} ui
      Icon=audio-input-microphone
      Terminal=false
      Type=Application
      Categories=Utility;AudioVideo;Audio;
      StartupNotify=true
      #{autostart ? "X-GNOME-Autostart-enabled=true" : ""}
    DESKTOP
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
