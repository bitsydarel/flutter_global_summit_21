#!/usr/bin/env bash

brew install lcov

pub global activate db_test_coverage 0.1.0

pub global activate dbstyleguidechecker 3.0.0-nullsafety.0

pub global activate vcshooks 1.0.0-nullsafety.0

pub global run vcshooks --project-type flutter --branch-naming-rule "(^(?=WA-\d+[\-]+[a-z\d]+)(?!.*[\@ \.\_]).*)|(^(?=release\/[a-z\d]+[-\/_\.]*[a-z\d]*)(?!.*[\@ ]).*)|(^(?=develop|master|main$).*)" --commit-message-rule "^(?=WA-\d+[a-z\d]+).*" .
