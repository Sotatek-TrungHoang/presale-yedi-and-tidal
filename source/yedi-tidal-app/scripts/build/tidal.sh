#!/usr/bin/env bash
./scripts/pre_tidal.sh && \
# flutter build appbundle --flavor tidal --dart-define-from-file .env.tidal && \
flutter build ios --flavor tidal --dart-define-from-file .env.tidal && \
flutter build ipa --flavor tidal --dart-define-from-file .env.tidal