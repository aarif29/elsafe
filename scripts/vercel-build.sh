#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_HOME="${VERCEL_FLUTTER_HOME:-$HOME/flutter}"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    --branch "$FLUTTER_VERSION" \
    --depth 1
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --enable-web
flutter pub get

build_args=(web --release)

if [ -n "${SUPABASE_URL:-}" ]; then
  build_args+=(--dart-define "SUPABASE_URL=$SUPABASE_URL")
fi

if [ -n "${SUPABASE_ANON_KEY:-}" ]; then
  build_args+=(--dart-define "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY")
fi

flutter build "${build_args[@]}"
