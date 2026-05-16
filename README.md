# FactusConsulting Homebrew tap

Personal tap for [`whisper-dictate`](https://github.com/FactusConsulting/whisper-dictate)
— local push-to-talk dictation.

```bash
brew tap factusconsulting/tap
brew install whisper-dictate
whisper-dictate            # same flags as voice_pi.py, e.g. --lang de
```

First run builds a machine-local venv and downloads the Whisper model
(idempotent — later runs just launch). **CPU only via brew** (no NVIDIA
acceleration). **Wayland:** global hotkey + auto-typing (pynput) are
X11-only; on GNOME/Wayland use an Xorg session or `--no-type`. A
clipboard tool (`wl-clipboard`/`xclip`) is needed for `--paste`.

Updating: bump `url` + `sha256` in `Formula/whisper-dictate.rb` to a
new release tag of the main repo.
