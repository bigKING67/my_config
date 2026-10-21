#!/usr/bin/env bash
# Claude Code statusLine：读取 stdin JSON，输出单行状态。字段见 https://code.claude.com/docs/en/statusline.md
input=$(cat)

IFS=$'\t' read -r model effort fast cwd project ctx_pct ctx_tok cost h5_pct h5_reset d7_pct d7_reset < <(
  jq -r '[
    (.model.display_name // "?" | sub(" \\(1M context\\)"; " 1M")),
    (.effort.level // "-"),
    (.fast_mode // false),
    (.workspace.current_dir // .cwd // ""),
    (.workspace.project_dir // ""),
    (.context_window.used_percentage // 0),
    ((.context_window.current_usage // {}) | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // "-"),
    (.rate_limits.five_hour.resets_at // "-"),
    (.rate_limits.seven_day.used_percentage // "-"),
    (.rate_limits.seven_day.resets_at // "-")
  ] | map(tostring) | join("\t")' <<<"$input"
)

R=$'\e[0m' DIM=$'\e[2m' CYAN=$'\e[96m' GREEN=$'\e[92m' YELLOW=$'\e[33m' MAGENTA=$'\e[95m' BLUE=$'\e[94m' RED=$'\e[91m'
SEP=" ${DIM}|${R} "

# ~ 缩写；超过 3 级只保留最后两级
short_path() {
  local p="${1/#$HOME/~}"
  local n; n=$(awk -F/ '{print NF}' <<<"$p")
  if (( n > 3 )); then p="…/$(basename "$(dirname "$p")")/$(basename "$p")"; fi
  printf '%s' "$p"
}

# 按阈值着色：≥80 红，≥50 黄，否则用默认色
level_color() {
  awk -v p="$1" -v d="$2" -v y="$YELLOW" -v r="$RED" 'BEGIN { print (p >= 80 ? r : (p >= 50 ? y : d)) }'
}

case "$effort" in
  low) ec=$DIM ;; medium) ec=$GREEN ;; high) ec=$YELLOW ;; xhigh|max) ec=$RED ;; *) ec="" ;;
esac
out="🤖 ${CYAN}${model}${R}"
[[ "$effort" != "-" ]] && out+=" ${ec}${effort}${R}"
[[ "$fast" == "true" ]] && out+=" ${MAGENTA}↯fast${R}"

dir=$(short_path "$cwd")
if [[ -n "$project" && "$project" != "$cwd" ]]; then
  if [[ "$project" == "$HOME" ]]; then pname="~"; else pname=$(basename "$project"); fi
  dir="${pname} ${DIM}→${R}${GREEN} ${dir}"
fi
out+="${SEP}📁 ${GREEN}${dir}${R}"

if branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null) && [[ -n "$branch" ]]; then
  out+="${SEP}🌿 ${BLUE}${branch}${R}"
fi

tok=$(awk -v t="$ctx_tok" 'BEGIN { if (t >= 1000) printf "%.1fk", t/1000; else printf "%d", t }')
out+="${SEP}⚡ $(level_color "$ctx_pct" "$MAGENTA")$(printf '%.1f' "$ctx_pct")% · ${tok}${R}"

if [[ "$h5_pct" != "-" || "$d7_pct" != "-" ]]; then
  lim=""
  if [[ "$h5_pct" != "-" ]]; then
    lim+="$(level_color "$h5_pct" "$CYAN")5h $(printf '%.0f' "$h5_pct")%"
    [[ "$h5_reset" != "-" ]] && lim+=" ↻$(date -r "$h5_reset" +%H:%M)"
  fi
  if [[ "$d7_pct" != "-" ]]; then
    [[ -n "$lim" ]] && lim+="${CYAN} · "
    lim+="$(level_color "$d7_pct" "$CYAN")7d $(printf '%.0f' "$d7_pct")%"
    [[ "$d7_reset" != "-" ]] && lim+=" ↻$(date -r "$d7_reset" +%m-%d)"
  fi
  out+="${SEP}⏱ ${CYAN}${lim}${R}"
fi

out+="${SEP}💰 ${YELLOW}\$$(printf '%.2f' "$cost")${R}"
printf '%s' "$out"
