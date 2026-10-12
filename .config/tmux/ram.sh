#!/usr/bin/env bash
# Used/total RAM in GB, e.g. "10.2/16G" (same "used" definition as tmux-cpu).
if command -v vm_stat >/dev/null; then
  total=$(sysctl -n hw.memsize)
  vm_stat | awk -v total="$total" '
    /page size of/ { ps = $8 }
    /Pages (active|inactive|speculative|wired down|occupied by compressor)/ { used += $NF }
    /Pages purgeable|File-backed pages/ { used -= $NF }
    END { printf "%.1f/%.0fG", used * ps / 2^30, total / 2^30 }'
else
  free -b | awk '$1 ~ /Mem/ { printf "%.1f/%.0fG", $3 / 2^30, $2 / 2^30 }'
fi
