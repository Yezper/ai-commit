#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  export TEST_REPO=$(mktemp -d)
  cd "$TEST_REPO"
  git init -q
  echo "test" > test.txt
  git add test.txt
  git commit -m "initial commit" > /dev/null
  echo "more" >> test.txt
  git add test.txt

  mkdir -p "$BATS_TEST_DIRNAME/mock-bin"

  # Create fake ai-commit-msg
  echo -e '#!/bin/bash\necho "fix: mock commit message"' > "$BATS_TEST_DIRNAME/mock-bin/ai-commit-msg"
  chmod +x "$BATS_TEST_DIRNAME/mock-bin/ai-commit-msg"

  # Patch ai-commit to redirect ~/bin/ai-commit-msg to the mock version
  cp "$BATS_TEST_DIRNAME/../ai-commit" "$BATS_TEST_DIRNAME/ai-commit-patched"
  sed -i '' "s|~/bin/ai-commit-msg|$BATS_TEST_DIRNAME/mock-bin/ai-commit-msg|" "$BATS_TEST_DIRNAME/ai-commit-patched"

  export GIT_EDITOR=true
}

teardown() {
  rm -rf "$TEST_REPO"
  rm -rf "$BATS_TEST_DIRNAME/mock-bin"
  rm -f "$BATS_TEST_DIRNAME/ai-commit-patched"
}

@test "fails outside Git repo" {
  tmpdir=$(mktemp -d)
  cd "$tmpdir"
  run "$BATS_TEST_DIRNAME/ai-commit-patched"
  assert_failure
  assert_output --partial "Error: Not inside a Git repository."
}

@test "handles no staged changes error from ai-commit-msg" {
  git reset
  echo -e '#!/bin/bash\necho "Error: No staged changes found"' > "$BATS_TEST_DIRNAME/mock-bin/ai-commit-msg"
  chmod +x "$BATS_TEST_DIRNAME/mock-bin/ai-commit-msg"
  run "$BATS_TEST_DIRNAME/ai-commit-patched"
  assert_failure
  assert_output --partial "Error: No staged changes found"
}

@test "commits with mocked ai-commit-msg and auto-confirm" {
  run bash -c "$BATS_TEST_DIRNAME/ai-commit-patched" <<< "y"
  assert_success
  git log -1 --pretty=%B | grep "fix: mock commit message"
}
