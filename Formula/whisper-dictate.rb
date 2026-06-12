class WhisperDictate < Formula
  desc "Local push-to-talk dictation -- speak prompts instead of typing them"
  homepage "https://github.com/FactusConsulting/whisper-dictate"
  url "https://github.com/FactusConsulting/whisper-dictate/releases/download/v1.9.6/whisper-dictate-linux-1.9.6.zip"
  sha256 "e328949a45bbaf9764c89c735adebc3206d1363207d1ff05c52c07c00111367a"
  license "MIT"

  depends_on "portaudio"
  depends_on "python@3.12"

  def install
    payload = Dir["whisper-dictate/*"]
    payload = Dir["*"] if payload.empty?
    libexec.install payload
    chmod 0755, libexec/"whisper-dictate"
    chmod 0755, libexec/"packaging/linux/ubuntu26.04/setup.sh"

    py = Formula["python@3.12"].opt_bin/"python3.12"
  (bin/"whisper-dictate").write <<~SH
    #!/bin/bash
    install_linux_app_icon() {
      local home="$1"
      local icon_src="#{libexec}/assets/whisper-dictate-logo.svg"
      local icon_path="$home/.local/share/icons/hicolor/scalable/apps/whisper-dictate.svg"
      [ -n "$home" ] || return 0
      [ -f "$icon_src" ] || return 0
      mkdir -p "$home/.local/share/icons/hicolor/scalable/apps" || return 0
      cp "$icon_src" "$icon_path" 2>/dev/null || true
      gtk-update-icon-cache -q "$home/.local/share/icons/hicolor" 2>/dev/null || true
    }

    repair_linux_desktop_entry() {
      local path="$1"
      local autostart="$2"
      local exec_path="#{opt_bin}/whisper-dictate"
      local icon_path="${HOME:-}/.local/share/icons/hicolor/scalable/apps/whisper-dictate.svg"
      [ -n "${HOME:-}" ] || return 0
      install_linux_app_icon "${HOME:-}"
      [ -f "$path" ] || return 0
      grep -Fq "whisper-dictate" "$path" || return 0
      if grep -Fq "Exec=${exec_path} ui" "$path" &&
         grep -Fq "Icon=${icon_path}" "$path" &&
         grep -Fq "StartupWMClass=whisper-dictate" "$path"; then
        return 0
      fi

      mkdir -p "$(dirname "$path")" || return 0
      {
        printf '%s\n' '[Desktop Entry]'
        printf '%s\n' 'Name=Whisper Dictate'
        printf '%s\n' 'Comment=Push-to-talk dictation settings and runtime control'
        printf 'Exec=%s ui\n' "$exec_path"
        printf 'Icon=%s\n' "$icon_path"
        printf '%s\n' 'Terminal=false'
        printf '%s\n' 'Type=Application'
        printf '%s\n' 'Categories=Utility;AudioVideo;Audio;'
        printf '%s\n' 'StartupNotify=true'
        printf '%s\n' 'StartupWMClass=whisper-dictate'
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
      install_linux_app_icon(home)
      repair_linux_desktop_entry(
        Pathname.new(home)/".local/share/applications/whisper-dictate.desktop",
        opt_bin/"whisper-dictate",
        false,
        home,
      )
      repair_linux_desktop_entry(
        Pathname.new(home)/".config/autostart/whisper-dictate.desktop",
        opt_bin/"whisper-dictate",
        true,
        home,
      )
    end
  end

  def linux_desktop_homes
    homes = [ENV["HOME"], *Dir["/home/*"]]
    homes.compact.uniq.select { |home| File.directory?(home) }
  end

  def repair_linux_desktop_entry(path, exe, autostart, home)
    return unless path.exist?

    raw = path.read
    return unless raw.include?("whisper-dictate")
    icon_path = linux_app_icon_path(home)
    return if raw.include?("Exec=#{exe} ui") &&
      raw.include?("Icon=#{icon_path}") &&
      raw.include?("StartupWMClass=whisper-dictate")

    path.dirname.mkpath
    File.write(path.to_s, <<~DESKTOP)
      [Desktop Entry]
      Name=Whisper Dictate
      Comment=Push-to-talk dictation settings and runtime control
      Exec=#{exe} ui
      Icon=#{icon_path}
      Terminal=false
      Type=Application
      Categories=Utility;AudioVideo;Audio;
      StartupNotify=true
      StartupWMClass=whisper-dictate
      #{autostart ? autostart_enabled_line(raw) : ""}
    DESKTOP
  rescue Errno::EACCES, Errno::EPERM
    nil
  end

  def install_linux_app_icon(home)
    icon_src = libexec/"assets/whisper-dictate-logo.svg"
    return unless icon_src.exist?

    icon_path = linux_app_icon_path(home)
    icon_path.dirname.mkpath
    cp icon_src, icon_path
    quiet_system "gtk-update-icon-cache", "-q", (Pathname.new(home)/".local/share/icons/hicolor").to_s
  rescue Errno::EACCES, Errno::EPERM
    nil
  end

  def linux_app_icon_path(home)
    Pathname.new(home)/".local/share/icons/hicolor/scalable/apps/whisper-dictate.svg"
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
    assert_path_exists libexec/"src/whisper_dictate/runtime.py"
    assert_path_exists libexec/"whisper-dictate"
    assert_path_exists libexec/"packaging/linux/ubuntu26.04/setup.sh"
    assert_match version.to_s, shell_output("#{bin}/whisper-dictate --version")
  end
end
