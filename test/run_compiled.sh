#!/bin/bash

set -euo pipefail

pushd "$(dirname "$0")/.." > /dev/null

source "test/logging.sh"

debug=
if [ "$1" == "-d" ]; then
  debug=1
  shift 1
fi

rb_file=$1
shift

if [ -z "$rb_file" ]; then
  echo "Usage: test/run_compiled.sh [-d] <test_file>"
  echo
  echo "  NOTE: if the 'llvmir' environmenet variable is set, that will be used"
  echo "        for compiler output instead."
  exit 1
fi

# Export llvmir so that run_sorbet picks it up. Real argument parsing in
# run_sorbet.sh would probably be better.
llvmir="$(mktemp -d)"
export llvmir

# ensure that the extension is built
"test/run_sorbet.sh" "$rb_file"

ruby="./bazel-bin/external/sorbet_ruby/toolchain/bin/ruby"

echo
info "Building Ruby..."

if [ -n "$debug" ]; then
  bazel build @sorbet_ruby//:ruby --config dbg
  command=("lldb" "--" "${ruby}")
else
  bazel build @sorbet_ruby//:ruby -c opt 2>/dev/null
  command=( "${ruby}" )
fi

# Use force_compile to make patch_require.rb fail if the compiled extension
# isn't found.
command=("${command[@]}" \
  "--disable=gems" \
  "--disable=did_you_mean" \
  -I "run/tools" -rpreamble.rb -rpatch_require.rb \
  -e "require './$rb_file'" \
  "$@" \
  )

echo
info "Running compiled Ruby output..."
info "├─ llvmir=\"$llvmir\" force_compile=1 ${command[*]}"

if llvmir="$llvmir" force_compile=1 "${command[@]}"; then
  success "└─ done."
else
  fatal "└─ Non-zero exit. See above."
fi
