# Discord PTT

An owned Omarchy+ service plugin for system-wide push-to-talk with Discord Web.
It preserves ordinary microphone behavior until PTT Mode is enabled, then uses
Caps Lock as a hold-to-talk key without requiring Discord to be focused.

## Accepted behavior

- PTT Mode disabled: the default microphone remains available to every app.
- Enable the Discord indicator: the default microphone is muted immediately.
- Hold Caps Lock: the microphone opens.
- Release Caps Lock: the microphone is muted again.
- Disable the indicator: the microphone opens immediately.
- The selected mode persists across login and shell restarts.

The indicator uses the `nf-fa-discord` glyph and the tooltip `Discord PTT`.

## Architecture

`omarchy-plus-discord-ptt` owns the microphone state machine. Its state marker
is stored with mode `0600` beneath:

```text
${XDG_STATE_HOME:-~/.local/state}/omarchy-plus/discord-ptt/enabled
```

Input-management companions must use the versioned `authority-v1` contract.
The helper serializes every mode transition and Caps Lock press/release beneath
`${XDG_RUNTIME_DIR}/omarchy-plus-discord-ptt/authority.lock`. A companion may
change capture state only while holding that same lock and after verifying PTT
is disabled. Missing or malformed authority state is fail-closed.

`Service.qml` reconciles the saved state whenever the Omarchy shell loads the
plugin. The helper controls only PipeWire's current default audio source through
`wpctl`; it does not target Discord's process or alter per-application streams.

Omarchy 4 does not currently expose third-party entries inside the built-in
hover-revealed indicator group. `PttMode.qml` is therefore an owned additive
bridge installed at the core indicator extension point by the central
Omarchy+ host reconciler. No existing Omarchy QML file is patched.

The Hugin host contract additionally owns:

- `keyd`, mapping Caps Lock to F13;
- Hyprland press and release bindings for `code:191`;
- the `PttMode` entry immediately after `Dictation` in `omarchy.indicators`;
- a stable helper command at `~/.local/bin/omarchy-plus-discord-ptt`.

Those privileged and host-specific files remain central Omarchy+ policy rather
than being mutated implicitly when this plugin is cloned.

## Helper interface

```text
omarchy-plus-discord-ptt enable
omarchy-plus-discord-ptt disable
omarchy-plus-discord-ptt toggle
omarchy-plus-discord-ptt press
omarchy-plus-discord-ptt release
omarchy-plus-discord-ptt status
omarchy-plus-discord-ptt reconcile
omarchy-plus-discord-ptt reset
```

`reset` and `disable` both remove the mode marker and explicitly unmute the
default microphone.

## Validate

```bash
./validate
```

## Install

After source review and publication:

```bash
omarchy plugin add https://github.com/ol4vr/omarchy-plus-discord-ptt.git --enable
```

The central Omarchy+ reconciler then installs the indicator bridge and Hugin
input contract from this pinned checkout.

## Remove

Disable PTT Mode before removing the host integration so the microphone is
left open:

```bash
omarchy-plus-discord-ptt reset
omarchy plugin remove io.github.ol4vr.discord-ptt
```

The central host removal path also removes the indicator bridge, Hyprland
bindings, keyd mapping, and shell entry.

## Privacy boundary

This plugin is local-only. It sends no telemetry, opens no network connection,
does not inspect Discord content, and does not record audio. It only changes the
mute state of the current default PipeWire input source.
