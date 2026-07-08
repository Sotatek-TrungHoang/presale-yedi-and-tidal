#!/usr/bin/env bash
./scripts/pre_yedi.sh
flutter build appbundle --flavor yedi --dart-define-from-file .env.yedi
flutter build ios --flavor yedi --dart-define-from-file .env.yedi
flutter build ipa --flavor yedi --dart-define-from-file .env.yedi