#!/usr/bin/env bash

dbstyleguidechecker --project-type flutter --reporter-type console .

test_coverage --package-name flutter_global_summit_21 --src-dir lib --min-cov 0.7 --project-type flutter . || exit

flutter build apk --profile

dir=$(pwd)

pushd android || exit

./gradlew app:assembleAndroidTest

./gradlew app:assembleProfile -Ptarget="$dir"/integration_test/app_performance_test.dart

popd || exit

gcloud components update

gcloud auth activate-service-account --key-file="$dir"/keys/flutter-global-submit-demo-gcloud.json

gcloud --quiet config set project flutter-global-submit-demo

gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/profile/app-profile.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --test-targets "package com.bitsydarel.flutter_global_summit_21" \
  --results-bucket=fgs21 \
  --results-dir=metrics \
  --performance-metrics \
  --record-video \
  --directories-to-pull "/sdcard" \
  --timeout 30m

rm -rf metrics

mkdir "metrics"

gsutil cp gs://fgs21/metrics/**.json metrics

file metrics/home.timeline.json
file metrics/home.timeline_summary.json
file metrics/scrolling.timeline_summary.json
file metrics/scrolling.timeline_summary.json
