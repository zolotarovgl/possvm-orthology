#!/usr/bin/env bash
# Run possvm N times on the same tree in fresh processes; pass iff all outputs are byte-identical.
set -u
POSSVM=$1; TREE=$2; N=${3:-5}; shift 3; W=$(mktemp -d)
cp "$TREE" "$W/t.tree"
for i in $(seq "$N"); do
  (cd "$W" && python3 "$POSSVM" -i t.tree -skipprint -ogprefix OG -method lpa "$@" >/dev/null 2>&1) || { echo "FAIL: run $i crashed"; exit 1; }
  md5sum < "$W/t.tree.ortholog_groups.csv"
done | sort -u | wc -l | { read k; [ "$k" -eq 1 ] && echo "PASS ($N identical runs)" || { echo "FAIL: $k distinct outputs in $N runs"; exit 1; }; }
