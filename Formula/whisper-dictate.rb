class WhisperDictate < Formula
  desc "Local push-to-talk dictation -- speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/releases/download/v0.3.37/whisper-dictate-linux-0.3.37.zip"
  sha256 "c1678d5a44ff45f186cb108bbc0f3d1f8d9a54871ac9dc18785426dcb8b48610"
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
    repair_linux_desktop_entry() {
      local path="$1"
      local autostart="$2"
      local exec_path="#{opt_bin}/whisper-dictate"
      [ -n "${HOME:-}" ] || return 0
      [ -f "$path" ] || return 0
      grep -Fq "whisper-dictate" "$path" || return 0
      grep -Fq "Exec=${exec_path} ui" "$path" && return 0

      mkdir -p "$(dirname "$path")" || return 0
      {
        printf '%s\n' '[Desktop Entry]'
        printf '%s\n' 'Name=Whisper Dictate'
        printf '%s\n' 'Comment=Push-to-talk dictation settings and runtime control'
        printf 'Exec=%s ui\n' "$exec_path"
        printf '%s\n' 'Icon=audio-input-microphone'
        printf '%s\n' 'Terminal=false'
        printf '%s\n' 'Type=Application'
        printf '%s\n' 'Categories=Utility;AudioVideo;Audio;'
        printf '%s\n' 'StartupNotify=true'
        if [ "$autostart" = "1" ]; then
          if grep -Fq 'X-GNOME-Autostart-enabled=false' "$path"; then
            printf '%s\n' 'X-GNOME-Autostart-enabled=false'
          else
            printf '%s\n' 'X-GNOME-Autostart-enabled=true'
          fi
        fi
      } > "$path" 2>/dev/null || true
    }

    if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
      repair_linux_desktop_entry "${HOME:-}/.local/share/applications/whisper-dictate.desktop" 0
      repair_linux_desktop_entry "${HOME:-}/.config/autostart/whisper-dictate.desktop" 1
    fi

    export VOICEPI_BOOTSTRAP_PYTHON="#{py}"
    export VOICEPI_APP_ROOT="#{libexec}"
    export VOICEPI_SKIP_SYSCHECK=1
    exec "#{libexec}/whisper-dictate" "$@"
  SH
end

  def post_install
    return unless OS.linux?

    linux_desktop_homes.each do |home|
      repair_linux_desktop_entry(
        Pathname.new(home)/".local/share/applications/whisper-dictate.desktop",
        opt_bin/"whisper-dictate",
        false,
      )
      repair_linux_desktop_entry(
        Pathname.new(home)/".config/autostart/whisper-dictate.desktop",
        opt_bin/"whisper-dictate",
        true,
      )
    end
  end

  def linux_desktop_homes
    homes = [ENV["HOME"], *Dir["/home/*"]]
    homes.compact.uniq.select { |home| File.directory?(home) }
  end

  def repair_linux_desktop_entry(path, exe, autostart)
    return unless path.exist?

    raw = path.read
    return unless raw.include?("whisper-dictate")
    return if raw.include?("Exec=#{exe} ui")

    path.dirname.mkpath
    File.write(path.to_s, <<~DESKTOP)
      [Desktop Entry]
      Name=Whisper Dictate
      Comment=Push-to-talk dictation settings and runtime control
      Exec=#{exe} ui
      Icon=audio-input-microphone
      Terminal=false
      Type=Application
      Categories=Utility;AudioVideo;Audio;
      StartupNotify=true
      #{autostart ? autostart_enabled_line(raw) : ""}
    DESKTOP
  rescue Errno::EACCES, Errno::EPERM
    nil
  end

  def autostart_enabled_line(raw)
    if raw.include?("X-GNOME-Autostart-enabled=false")
      "X-GNOME-Autostart-enabled=false"
    else
      "X-GNOME-Autostart-enabled=true"
    end
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
