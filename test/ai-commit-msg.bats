#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  export TEST_REPO=$(mktemp -d)
  cd "$TEST_REPO"
  git init -q
  touch test.txt
  git add test.txt
  git commit -m "initial commit" > /dev/null
  echo "test" > test.txt
  git add test.txt
  export OPENAI_API_KEY="sk-test123"
  mkdir -p ~/tmp
}

teardown() {
  rm -rf "$TEST_REPO"
}

@test "fails if OPENAI_API_KEY is unset" {
  unset OPENAI_API_KEY
  run "$BATS_TEST_DIRNAME/../ai-commit-msg"
  assert_failure
  assert_output --partial "Error: OPENAI_API_KEY environment variable is not set"
}

@test "fails if no staged changes" {
  git reset
  run "$BATS_TEST_DIRNAME/../ai-commit-msg"
  assert_failure
  assert_output --partial "Error: No staged changes found"
}

@test "generates commit message with mocked API" {
  # Replace curl with mock
  export PATH="$BATS_TEST_DIRNAME/mock-bin:$PATH"
  mkdir -p "$BATS_TEST_DIRNAME/mock-bin"
  echo -e '#!/bin/bash\necho "{\"choices\":[{\"message\":{\"content\":\"fix: test commit message\"}}]}"' > "$BATS_TEST_DIRNAME/mock-bin/curl"
  chmod +x "$BATS_TEST_DIRNAME/mock-bin/curl"

  run "$BATS_TEST_DIRNAME/../ai-commit-msg"
  assert_success
  assert_output --partial "fix: test commit message"
}
