# tmux-launcher

Open command launchers inside tmux with `prefix+key` bindings and reuse each
launcher window across the current tmux session.

## Installation

### Manual installation

Clone this folder wherever you keep your tmux plugins, then add this line to
your `tmux.conf`:

```bash
run-shell <clone-path>/tmux-launcher.tmux
```

Reload tmux:

```bash
tmux source-file <tmux.conf-path>
```

## Behavior

Each key binding reuses a single window per tmux session. The plugin stores the
tracked window id directly in tmux session memory using a session-scoped user
option. If that window already exists, it focuses it instead of creating a new
one.

## Configuration options

### `@tmux-launchers`

**Default:**

```tmux
set -g @tmux-launchers 'key=a window=- command=opencode'
```

Multiline launcher definitions. Each line uses named fields: `key`, `window`,
and `command`.

- `key` is the tmux key used with the leader
- `window` is the preferred tmux window index, or `-` to use default placement
- `command` is the shell command to run

```tmux
set -g @tmux-launchers "
key=a window=3 command=opencode --theme gruvbox
key=b window=7 command=lazygit
key=c window=- command=npm run dev
"
```
