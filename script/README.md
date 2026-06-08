# statusline.sh — Agent Installation Guide

## Prerequisites

- `jq` must be installed. If missing, all values will be empty.
  ```bash
  sudo apt install -y jq        # Ubuntu / Debian / WSL
  brew install jq               # macOS
  ```

## Installation

1. Copy the script:
   ```bash
   cp statusline.sh ~/.claude/statusline-command.sh
   chmod +x ~/.claude/statusline-command.sh
   ```

2. Add to `~/.claude/settings.json`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash /home/<username>/.claude/statusline-command.sh"
     }
   }
   ```
   Replace `<username>` with the actual system username, or use an absolute path.

3. Restart Claude Code for the setting to take effect.

4. Verify `jq` is installed — if the statusline shows empty values, install it manually:
   ```bash
   jq --version || sudo apt install -y jq   # Ubuntu / Debian / WSL
   jq --version || brew install jq          # macOS
   ```

## Output Format

Two lines are printed to stdout on every statusline refresh.

```
<model> <ctx_size> v<version> | <repo> (<branch>) | +N -N lines
<bar> <pct>% | <duration> | 5h <pct>% (<reset>) | 7d <pct>% (<reset>) | cache <pct>%
```

### Fields

| Line | Field | Source JSON path |
|------|-------|-----------------|
| L1 | Model name | `.model.display_name` |
| L1 | Context size (`1M` / `200K`) | `.context_window.context_window_size` |
| L1 | Version | `.version` |
| L1 | Repo / directory | `.workspace.current_dir` + git remote |
| L1 | Branch | git `branch --show-current` |
| L1 | Lines added/removed | `.cost.total_lines_added` / `.cost.total_lines_removed` |
| L2 | Context bar (`●○`) | `.context_window.used_percentage` |
| L2 | Duration | `.cost.total_duration_ms` |
| L2 | 5h rate limit + countdown | `.rate_limits.five_hour.*` |
| L2 | 7d rate limit + countdown | `.rate_limits.seven_day.*` |
| L2 | Cache hit rate | `.context_window.current_usage.*` |

### Color thresholds (applied to all percentage values)

| Range | Color |
|-------|-------|
| ≥ 80% | Red |
| ≥ 50% | Yellow |
| < 50% | Green |

## Troubleshooting

**All values empty, only labels show** → `jq` not installed. Run `sudo apt install -y jq`.

**Colors broken on macOS** → Replace `echo -e` with `printf '%b\n'` in the last two lines of the script.

**Wrong JSON paths** → Dump the input for inspection:
```bash
# Add after `input=$(cat)`:
printf '%s' "$input" > /tmp/statusline-input.json
# Then: cat /tmp/statusline-input.json | jq .
# Remove the line after debugging.
```
