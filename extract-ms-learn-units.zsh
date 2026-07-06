#!/bin/zsh
# Copyright (C) 2026 Jim Chen <Jim@ChenJ.im>, licensed under GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ==================================================================
#
# Extract unit URLs from Microsoft Learn learning path or module pages,
# automatically excluding Introduction, Summary, and Knowledge check units.
#
# Usage:
#   ./extract-ms-learn-units.zsh [-v|--verbose] [--dump-dir DIR] <url> [url2 ...]
#
# Options:
#   -v, --verbose     Print debug messages to stderr (does not affect stdout)
#   --dump-dir DIR    Save raw HTML of fetched pages into DIR/ for debugging
#   -h, --help        Display this help message and exit

emulate -L zsh
setopt pipefail extended_glob

# Global configuration and state variables
typeset -g VERBOSE=0
typeset -g DUMP_DIR=""
typeset -g BASE="${BASE:-https://learn.microsoft.com}"
typeset -g UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36"
typeset -g SLEEP_BETWEEN="0.3"
typeset -g SCRIPT_NAME="${0:t}"
typeset -ga INPUT_URLS=()
typeset -g TMPFILE=""

# Color codes for user feedback
typeset -g RED='\033[0;31m'
typeset -g YELLOW='\033[1;33m'
typeset -g GRAY='\033[0;90m'
typeset -g RESET='\033[0m'

# ==================================================================
# 1. Utility functions
# ==================================================================

# Print debug messages when verbose mode is enabled
log() {
  (( VERBOSE )) && print -u2 -- "${GRAY}[debug] $*${RESET}"
}

# Print warning messages to stderr
warn() {
  print -u2 -- "${YELLOW}[warn] $*${RESET}"
}

# Print error messages to stderr and terminate execution
die() {
  print -u2 -- "${RED}[error] $*${RESET}"
  exit 1
}

# Display script usage instructions
usage() {
  print -- "Usage: ${SCRIPT_NAME} [-v|--verbose] [--dump-dir DIR] <url> [url2 ...]"
}

# Check if all required external tools are installed (fail fast)
check_dependencies() {
  local cmd
  for cmd in curl grep awk sed mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      die "${cmd} is required but not installed."
    fi
  done
}

# Initialize temporary file with cleanup trap
setup_tmpfile() {
  TMPFILE=$(mktemp)
  trap "rm -f -- \"\$TMPFILE\"" EXIT INT TERM
}

# Remove query strings and anchors from a URL
strip_query_fragment() {
  local u="$1"
  u="${u%%\#*}"
  u="${u%%\?*}"
  print -- "$u"
}

# Sanitize string to create a safe filename for --dump-dir
safe_name() {
  print -- "${1//[^A-Za-z0-9_.-]/_}"
}

# ==================================================================
# 2. Content processing functions
# ==================================================================

# Download raw HTML from a URL into the global temporary file
fetch_html() {
  local url="$1"
  curl -fsSL --compressed \
    -A "$UA" \
    -H "Accept: text/html,application/xhtml+xml" \
    -H "Accept-Language: en-US,en;q=0.9" \
    --retry 3 --retry-delay 1 --max-time 30 \
    "$url" > "$TMPFILE"
}

# Extract locale (e.g., "zh-tw" or "en-us") from a Microsoft Learn URL
extract_locale() {
  local url="$1"
  local path="${url#*learn.microsoft.com/}"
  path="${path#/}"
  local locale="${path%%/*}"
  if [[ "$locale" =~ ^[a-z]{2}-[a-z0-9]+$ ]]; then
    print -- "$locale"
  else
    print -- "en-us"
  fi
}

# Check if a unit slug should be excluded from output
is_excluded_unit() {
  local slug="${(L)1}"
  [[ "$slug" == *introduction* || "$slug" == *summary* || "$slug" == *knowledge-check* ]]
}

# Extract module canonical URLs from a learning path page
get_module_urls() {
  local path_url="$(strip_query_fragment "$1")"
  local locale="$(extract_locale "$path_url")"

  if ! fetch_html "$path_url"; then
    warn "Failed to download path URL: $path_url"
    return 1
  fi

  if [[ -n "$DUMP_DIR" ]]; then
    mkdir -p -- "$DUMP_DIR"
    cp -- "$TMPFILE" "$DUMP_DIR/$(safe_name "$path_url").html"
  fi

  local -a slugs
  slugs=("${(f)$(grep -oE 'modules/[A-Za-z0-9_-]+' "$TMPFILE" | sed 's|^modules/||' | awk '!seen[$0]++')}")
  log "Found ${#slugs[@]} module links in path: $path_url"

  local slug
  for slug in "${slugs[@]}"; do
    [[ -z "$slug" ]] && continue
    print -- "${BASE}/${locale}/training/modules/${slug}/"
  done
}

# Extract unit URLs from a module page, filtering out excluded units
get_unit_urls() {
  local module_url="$(strip_query_fragment "$1")"
  local locale="$(extract_locale "$module_url")"
  local slug="${module_url%/}"
  slug="${slug##*/modules/}"
  slug="${slug%%/*}"
  [[ -z "$slug" ]] && { warn "Cannot parse module slug from URL: $module_url"; return 1; }

  local canonical_url="${BASE}/${locale}/training/modules/${slug}/"
  if ! fetch_html "$canonical_url"; then
    warn "Failed to download module URL: $canonical_url"
    return 1
  fi

  if [[ -n "$DUMP_DIR" ]]; then
    mkdir -p -- "$DUMP_DIR"
    cp -- "$TMPFILE" "$DUMP_DIR/$(safe_name "$slug").html"
  fi

  # Extract unit slugs by matching relative unit links (e.g., "1-introduction")
  # and absolute module unit links
  local -a unit_slugs
  unit_slugs=("${(f)$(grep -oE '(href="[0-9]+-[A-Za-z0-9_-]+"|/training/modules/'"$slug"'/[A-Za-z0-9_-]+)' "$TMPFILE" | sed -E 's/.*href="([0-9]+-[A-Za-z0-9_-]+)".*/\1/; s/.*\/([A-Za-z0-9_-]+)$/\1/' | awk '!seen[$0]++')}")

  local unit_slug
  local -i kept=0 skipped=0
  for unit_slug in "${unit_slugs[@]}"; do
    [[ -z "$unit_slug" ]] && continue
    if is_excluded_unit "$unit_slug"; then
      log "Skipping excluded unit: $unit_slug"
      (( skipped++ ))
      continue
    fi
    (( kept++ ))
    print -- "${BASE}/${locale}/training/modules/${slug}/${unit_slug}"
  done
  log "Module ${slug}: kept ${kept} units, skipped ${skipped} units"
}

# ==================================================================
# 3. Main execution function
# ==================================================================

main() {
  check_dependencies
  setup_tmpfile

  (( ${#INPUT_URLS[@]} == 0 )) && { usage; die "At least one Learning Path or Module URL is required."; }

  local url mod_url
  local -a mod_urls
  for url in "${INPUT_URLS[@]}"; do
    log "Processing input URL: $url"
    if [[ "$url" == *"/training/paths/"* ]]; then
      mod_urls=("${(f)$(get_module_urls "$url")}")
      for mod_url in "${mod_urls[@]}"; do
        [[ -z "$mod_url" ]] && continue
        get_unit_urls "$mod_url"
        sleep "$SLEEP_BETWEEN"
      done
    elif [[ "$url" == *"/training/modules/"* ]]; then
      get_unit_urls "$url"
      sleep "$SLEEP_BETWEEN"
    else
      warn "Unrecognized URL format (neither path nor module), skipping: $url"
    fi
  done
}

# ==================================================================
# 4. Parameter handling
# ==================================================================

parse_args() {
  while (( $# )); do
    case "$1" in
      -v|--verbose)
        VERBOSE=1
        ;;
      --dump-dir)
        shift
        [[ -z "$1" ]] && die "Option --dump-dir requires an argument."
        DUMP_DIR="$1"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        warn "Unknown option ignored: $1"
        ;;
      *)
        INPUT_URLS+=("$1")
        ;;
    esac
    shift
  done
}

parse_args "$@"
main
