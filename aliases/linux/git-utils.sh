#!/bin/bash

# Strubloid::linux::git-utils
#
# Visualization helpers for git workflows (currently: rebase before/after
# preview). All public functions in this file use the `git-show-*` prefix.

# ---------------------------------------------------------------------------
# Colors used by the show-* helpers. Blue for the base branch (origin/<BASE>),
# green for the current branch's commits. Exposed as globals so they can be
# tweaked or overridden by callers (e.g. set GIT_GRAPH_NC="" to disable color).
GIT_GRAPH_BASE_COLOR="${GIT_GRAPH_BASE_COLOR:-$(printf '\033[1;34m')}"   # bold blue
GIT_GRAPH_BRANCH_COLOR="${GIT_GRAPH_BRANCH_COLOR:-$(printf '\033[1;32m')}" # bold green
GIT_GRAPH_NC="${GIT_GRAPH_NC:-$(printf '\033[0m')}"                       # no color

# Internal helper: draws one horizontal commit line.
#   $1 = label (or "" for blank)
#   $2 = color
#   $3 = extra_offset (chars to shift the commit row rightward, beyond the
#       standard label width of 13). Used by the branch row so its commits
#       visually start at the backslash column rather than at col 14.
#   $@ = remaining args are commit short-hashes (in display order)
git-graph-draw-row() {
  local label="$1"
  local color="$2"
  local extra_offset="$3"
  shift 3

  # Total padding before the first commit: standard label area (13 chars)
  # plus any extra offset (e.g. to align branch commits with the backslash).
  local pad_target=$((13 + extra_offset))

  if [ -n "$label" ]; then
    printf "%-${pad_target}s" "$label"
  else
    printf "%${pad_target}s" ""
  fi

  local first=1
  for commit in "$@"; do
    if [ "$first" -eq 1 ]; then
      printf "%s%s%s" "$color" "$commit" "$GIT_GRAPH_NC"
      first=0
    else
      # The `--` is required: bash's printf builtin interprets a format
      # string starting with `--` as an (invalid) option. Using `--` as the
      # explicit option terminator sidesteps that.
      printf -- "---%s%s%s" "$color" "$commit" "$GIT_GRAPH_NC"
    fi
  done
  echo ""
}

# Internal helper: prints the backslash row that visually connects the base
# branch row to the current branch row. Position is controlled by which slot
# the branch diverges at (0-indexed from the leftmost base commit, where the
# divergence line sits BETWEEN that slot and the next one).
#
#   $1 = label width (chars to skip on the left)
#   $2 = divergence slot (0-indexed; for "after" this is the LAST base slot)
git-graph-draw-divergence() {
  local label_width="$1"
  local diverge_slot="$2"
  # Each commit slot is 10 chars wide (7-char short hash + 3-char "---").
  # The divergence line sits immediately AFTER commit[diverge_slot], so its
  # column is label_width + (diverge_slot + 1) * 10.
  local col=$(( label_width + (diverge_slot + 1) * 10 ))
  printf "%${col}s%c\n" "" "\\"
}

# Internal helper: shared body for both views inside the wrapper.
# Prints the full ASCII graph for the given divergence slot, plus a header
# summary (merge-base SHA + branch-only commit count + branch tip + base tip).
#
#   $1 = header label (e.g. "[before rebase]" or "[after rebase]")
#   $2 = BASE_BRANCH (already resolved, must exist locally on remote)
#   $3 = divergence slot (0-indexed; -1 = end-of-base, used by "after" view)
git-graph-render() {
  local HEADER="$1"
  local BASE_BRANCH="$2"
  local DIVERGE_SLOT="$3"

  local DEPTH="${GIT_SHOW_REBASE_DEPTH:-10}"

  # Refuse to render if we can't determine the current branch.
  local CURRENT_BRANCH
  CURRENT_BRANCH=$(git branch --show-current)
  if [ -z "$CURRENT_BRANCH" ]; then
    echo "[ERR]: Not on a branch (detached HEAD?). Cannot determine scope." >&2
    return 1
  fi

  # Pull base commits (most recent first) and reverse them into display order
  # so the leftmost is the oldest and the rightmost is the newest (matching
  # the conventional A---B---C---D left-to-right reading order).
  #
  # The trailing `printf '\n'` is required because `git log` does not emit a
  # newline after its last commit, and `while read` silently drops any line
  # without a terminator — which would lose the most recent commit.
  local -a BASE_COMMITS
  while IFS= read -r line; do
    # Skip the empty line emitted by the trailing `printf '\n'` (which exists
    # to ensure the final commit without a trailing newline is still captured
    # by `read`).
    [ -n "$line" ] && BASE_COMMITS+=("$line")
  done < <(git log --format='%h' "origin/${BASE_BRANCH}" -n "${DEPTH}" 2>/dev/null | tac; printf '\n')

  if [ ${#BASE_COMMITS[@]} -eq 0 ]; then
    echo "[ERR]: No commits found on origin/${BASE_BRANCH}" >&2
    return 1
  fi

  # Branch-only commits (HEAD not in origin/<BASE>), also in display order.
  local -a BRANCH_COMMITS
  while IFS= read -r line; do
    # Skip the empty line emitted by the trailing `printf '\n'` (see note in
    # BASE_COMMITS block above).
    [ -n "$line" ] && BRANCH_COMMITS+=("$line")
  done < <(git log --format='%h' "HEAD" "^origin/${BASE_BRANCH}" 2>/dev/null | tac; printf '\n')

  if [ ${#BRANCH_COMMITS[@]} -eq 0 ]; then
    echo "[ERR]: No branch-only commits (HEAD already matches origin/${BASE_BRANCH})" >&2
    return 1
  fi

  # Resolve divergence slot. For "before" the caller passes the merge-base
  # index. For "after" the caller passes -1 to mean "end of base".
  if [ "$DIVERGE_SLOT" -lt 0 ]; then
    DIVERGE_SLOT=$(( ${#BASE_COMMITS[@]} - 1 ))
  fi

  # Summary header
  local MERGE_BASE BRANCH_TIP BASE_TIP BRANCH_COUNT
  MERGE_BASE=$(git merge-base HEAD "origin/${BASE_BRANCH}" 2>/dev/null | cut -c1-7)
  BRANCH_TIP=$(git rev-parse --short HEAD 2>/dev/null)
  BASE_TIP=$(git rev-parse --short "origin/${BASE_BRANCH}" 2>/dev/null)
  BRANCH_COUNT=${#BRANCH_COMMITS[@]}

  echo ""
  echo "${HEADER}"
  echo "-----------------------------------------------------------------------------"
  echo "[MERGE BASE]    - ${MERGE_BASE:-none}"
  echo "[BASE TIP]      - ${BASE_TIP} (origin/${BASE_BRANCH})"
  echo "[BRANCH TIP]    - ${BRANCH_TIP} (${CURRENT_BRANCH})"
  echo "[BRANCH-ONLY]   - ${BRANCH_COUNT} commit(s) to be replayed"
  echo "-----------------------------------------------------------------------------"

  # Render the three rows. The base row starts at the standard label column.
  # The branch row is shifted right by `BRANCH_OFFSET` chars so its commits
  # visually start at the backslash column (rather than overlapping with the
  # base row). The divergence row sits exactly between them.
  local BRANCH_OFFSET=$(( (DIVERGE_SLOT + 1) * 10 ))
  git-graph-draw-row "main:" "$GIT_GRAPH_BASE_COLOR" 0 "${BASE_COMMITS[@]}"
  git-graph-draw-divergence 13 "$DIVERGE_SLOT"
  git-graph-draw-row "your branch:" "$GIT_GRAPH_BRANCH_COLOR" "$BRANCH_OFFSET" "${BRANCH_COMMITS[@]}"
  echo ""
}

## Shows both the current branch topology (BEFORE a rebase) and the predicted
## post-rebase topology in a single glance, side-by-side.
##
## Visual output:
##
##   [before rebase]
##   main:               A---B---C---D
##                             \
##   your branch:                E---F
##
##   ▼  after rebase  ▼
##
##   [after rebase]
##   main:               A---B---C---D
##                                     \
##   your branch:                        E---F
##
## This does NOT actually rebase — it only computes both views from the
## current ref state and the latest fetched origin/<BASE>. Call `git fetch`
## first if you want the most up-to-date base.
##
## Args:
##   $1 (optional) - base branch. Falls back to main > master.
##
## Honors:
##   $GIT_SHOW_REBASE_DEPTH (default 10) - how many base commits to show
##   $GIT_GRAPH_BASE_COLOR / $GIT_GRAPH_BRANCH_COLOR / $GIT_GRAPH_NC - colors
git-show-before-and-after-rebase() {

  # Resolve the base branch ONCE so both views agree on what "base" means.
  local BASE_BRANCH
  BASE_BRANCH=$(git-default-base-branch "$1") || return 1

  # Locate the merge-base inside the base history so the "before" divergence
  # row points at the right slot.
  local MERGE_BASE
  MERGE_BASE=$(git merge-base HEAD "origin/${BASE_BRANCH}" 2>/dev/null)
  local BEFORE_SLOT=0
  if [ -n "$MERGE_BASE" ]; then
    local DEPTH="${GIT_SHOW_REBASE_DEPTH:-10}"
    local -a BASE_COMMITS
    while IFS= read -r line; do
      [ -n "$line" ] && BASE_COMMITS+=("$line")
    done < <(git log --format='%h' "origin/${BASE_BRANCH}" -n "${DEPTH}" 2>/dev/null | tac; printf '\n')
    local MERGE_BASE_SHORT="${MERGE_BASE:0:7}"
    local i
    for i in "${!BASE_COMMITS[@]}"; do
      if [ "${BASE_COMMITS[$i]}" = "${MERGE_BASE_SHORT}" ]; then
        BEFORE_SLOT=$i
        break
      fi
    done
    # If the merge-base isn't in the visible base window, fall back to the
    # leftmost visible commit so the divergence still renders somewhere
    # sensible rather than off-screen.
    [ "$BEFORE_SLOT" -lt 0 ] && BEFORE_SLOT=0
  fi

  git-graph-render "[before rebase]" "$BASE_BRANCH" "$BEFORE_SLOT"

  echo "============================================================================="
  echo "                              ▼  after rebase  ▼"
  echo "============================================================================="

  # Pass -1 to signal "divergence at end of base" — that's exactly what a
  # rebase produces (branch-only commits sit on top of the full base history).
  git-graph-render "[after rebase]" "$BASE_BRANCH" -1
}
