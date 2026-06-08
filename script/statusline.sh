#!/bin/bash
input=$(cat)

# ── Parse JSON ────────────────────────────────────────────────
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
LINES_ADD=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
LINES_DEL=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
VIM_MODE=$(echo "$input" | jq -r '.vim.mode // empty')
AGENT=$(echo "$input" | jq -r '.agent.name // empty')
VERSION=$(echo "$input" | jq -r '.version // empty')




# Rate limits
RATE_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RATE_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RESET_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
RESET_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
CUR_INPUT=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')

# ── Colors ────────────────────────────────────────────────────
RESET='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'
RED='\033[31m'; MAGENTA='\033[35m'; BLUE='\033[34m'
WHITE='\033[37m'

SEP="${DIM} | ${RESET}"

# ── Helper: color by percentage ───────────────────────────────
color_pct() {
  local val=$1
  if [ "$val" -ge 80 ]; then echo "$RED"
  elif [ "$val" -ge 50 ]; then echo "$YELLOW"
  else echo "$GREEN"; fi
}

# ── Helper: format duration from ms ───────────────────────────
fmt_dur() {
  local ms=$1
  local total_sec=$(( ms / 1000 ))
  local h=$(( total_sec / 3600 ))
  local m=$(( (total_sec % 3600) / 60 ))
  local s=$(( total_sec % 60 ))
  if [ "$h" -gt 0 ]; then printf "%dh %02dm" "$h" "$m"
  elif [ "$m" -gt 0 ]; then printf "%dm %02ds" "$m" "$s"
  else printf "%ds" "$s"; fi
}

# ── Helper: format countdown from epoch ───────────────────────
fmt_countdown() {
  local reset_at=$1
  local now=$(date +%s)
  local diff=$(( reset_at - now ))
  if [ "$diff" -le 0 ]; then echo "now"; return; fi
  local h=$(( diff / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  printf "%dh %dm" "$h" "$m"
}

# ── Context window size label ─────────────────────────────────
CTX_LABEL=""
if [ -n "$CTX_SIZE" ]; then
  if [ "$CTX_SIZE" -ge 1000000 ]; then
    CTX_LABEL="${DIM}1M${RESET}"
  else
    CTX_LABEL="${DIM}200K${RESET}"
  fi
fi

# ── Git info ──────────────────────────────────────────────────
BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH="$(git branch --show-current 2>/dev/null)"

REPO_LINK="${DIR##*/}"
REMOTE=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
if [ -n "$REMOTE" ]; then
  REPO_NAME=$(basename "$REMOTE")
  REPO_LINK=$(printf '%b' "\e]8;;${REMOTE}\a${REPO_NAME}\e]8;;\a")
fi

# ── Context bar ───────────────────────────────────────────────
BAR_COLOR=$(color_pct "$PCT")
BAR_W=15
FILLED=$((PCT * BAR_W / 100)); EMPTY=$((BAR_W - FILLED))
BAR=""
for i in $(seq 1 $FILLED); do BAR="${BAR}${BAR_COLOR}●${RESET}"; done
for i in $(seq 1 $EMPTY); do BAR="${BAR}${DIM}●${RESET}"; done

# ── Duration ──────────────────────────────────────────────────
DUR=$(fmt_dur "$DURATION_MS")

# ── Cache hit rate ────────────────────────────────────────────
CACHE_HIT=""
if [ -n "$CACHE_READ" ] && [ -n "$CUR_INPUT" ] && [ "$CUR_INPUT" != "0" ] && [ "$CUR_INPUT" != "null" ]; then
  CACHE_TOTAL=$((CACHE_READ + CUR_INPUT + ${CACHE_CREATE:-0}))
  if [ "$CACHE_TOTAL" -gt 0 ]; then
    CACHE_PCT=$((CACHE_READ * 100 / CACHE_TOTAL))
    CACHE_C=$(color_pct "$((100 - CACHE_PCT))")
    CACHE_HIT="${DIM}cache${RESET} ${CACHE_C}${CACHE_PCT}%${RESET}"
  fi
fi

# ══════════════════════════════════════════════════════════════
# LINE 1: Model + Context size + Version + Repo + Branch + Lines + Agent
# ══════════════════════════════════════════════════════════════
L1="${CYAN}${BOLD}${MODEL}${RESET}"
[ -n "$CTX_LABEL" ] && L1="${L1} ${CTX_LABEL}"
[ -n "$VERSION" ] && L1="${L1} ${DIM}v${VERSION}${RESET}"
L1="${L1}${SEP}${WHITE}${REPO_LINK}${RESET}"
[ -n "$BRANCH" ] && L1="${L1} ${DIM}(${BRANCH})${RESET}"

# Lines added/removed
LINES_PART=""
if [ -n "$LINES_ADD" ] && [ "$LINES_ADD" != "0" ]; then
  LINES_PART="${GREEN}+${LINES_ADD}${RESET}"
fi
if [ -n "$LINES_DEL" ] && [ "$LINES_DEL" != "0" ]; then
  [ -n "$LINES_PART" ] && LINES_PART="${LINES_PART} ${RED}-${LINES_DEL}${RESET}" || LINES_PART="${RED}-${LINES_DEL}${RESET}"
fi
[ -n "$LINES_PART" ] && L1="${L1}${SEP}${LINES_PART} ${DIM}lines${RESET}"

[ -n "$AGENT" ] && L1="${L1}${SEP}${MAGENTA}${AGENT}${RESET}"
[ -n "$VIM_MODE" ] && {
  if [ "$VIM_MODE" = "NORMAL" ]; then
    L1="${L1}${SEP}${BLUE}${BOLD}NOR${RESET}"
  else
    L1="${L1}${SEP}${GREEN}${BOLD}INS${RESET}"
  fi
}

# ══════════════════════════════════════════════════════════════
# LINE 2: Context bar + Duration + Rate limits (5h & 7d with countdown) + Cache
# ══════════════════════════════════════════════════════════════
L2="${BAR} ${DIM}${PCT}%${RESET}"

if [ -n "$RATE_5H" ]; then
  R5_INT=$(printf "%.0f" "$RATE_5H")
  R5_C=$(color_pct "$R5_INT")
  L2="${L2}${SEP}${DIM}5h${RESET} ${R5_C}${R5_INT}%${RESET}"
  if [ -n "$RESET_5H" ] && [ "$RESET_5H" != "null" ]; then
    R5_CD=$(fmt_countdown "$RESET_5H")
    L2="${L2} ${DIM}(${R5_CD})${RESET}"
  fi
fi

if [ -n "$RATE_7D" ]; then
  R7_INT=$(printf "%.0f" "$RATE_7D")
  R7_C=$(color_pct "$R7_INT")
  L2="${L2}${SEP}${DIM}7d${RESET} ${R7_C}${R7_INT}%${RESET}"
  if [ -n "$RESET_7D" ] && [ "$RESET_7D" != "null" ]; then
    R7_CD=$(fmt_countdown "$RESET_7D")
    L2="${L2} ${DIM}(${R7_CD})${RESET}"
  fi
fi

[ -n "$CACHE_HIT" ] && L2="${L2}${SEP}${CACHE_HIT}"
L2="${L2}${SEP}${DIM}${DUR}${RESET}"

# ── Output ────────────────────────────────────────────────────
echo -e "$L1"
echo -e "$L2"
