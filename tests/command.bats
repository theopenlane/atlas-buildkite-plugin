#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
# export WHICH_STUB_DEBUG=/dev/tty

@test "default step" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="funk"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_COMMIT="24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
  export CONTEXT=$(cat <<EOF
{
    "branch": "funk",
    "commit": "24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
}
EOF
)

  stub atlas \
    'migrate lint --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR -w --format "{{ json .  }}" --context "$CONTEXT" : echo lint' \
    'migrate validate --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR : echo validate' \

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "+++ :database: lint"
  assert_output --partial "lint"
  assert_output --partial "validate"

  unstub atlas
}

@test "lint only step" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="funk"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_PLUGIN_ATLAS_STEP="lint"
  export BUILDKITE_COMMIT="24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
  export CONTEXT=$(cat <<EOF
{
    "branch": "funk",
    "commit": "24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
}
EOF
)

  stub atlas \
    'migrate lint --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR -w --format "{{ json .  }}" --context "$CONTEXT" : echo lint' \
    'migrate validate --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR : echo validate' \

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "+++ :database: lint and validate"
  assert_output --partial "lint"
  assert_output --partial "validate"

  unstub atlas
}

@test "migrate only step, on default branch" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="main"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_PLUGIN_ATLAS_STEP="migrate"
  export BUILDKITE_COMMIT="24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
  export CONTEXT=$(cat <<EOF
{
    "branch": "main",
    "commit": "24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
}
EOF
)

  stub atlas \
    'migrate push $BUILDKITE_PLUGIN_ATLAS_PROJECT --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR --context "$CONTEXT" : echo push' \

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "push"

  unstub atlas
}

@test "migrate only step, on non-default" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="meow"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_PLUGIN_ATLAS_STEP="migrate"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "not pushing migration"
}

@test "do it all on main" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="main"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_PLUGIN_ATLAS_STEP="all"
  export BUILDKITE_COMMIT="24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
  export CONTEXT=$(cat <<EOF
{
    "branch": "main",
    "commit": "24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
}
EOF
)

  stub atlas \
    'migrate lint --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR -w --format "{{ json .  }}" --context "$CONTEXT" : echo lint' \
    'migrate validate --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR : echo validate' \
    'migrate push $BUILDKITE_PLUGIN_ATLAS_PROJECT --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR --context "$CONTEXT" : echo push' \
    'migrate apply --env "turso" --config "file://atlas.hcl" : echo apply' \


  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "+++ :database: lint"
  assert_output --partial "lint"
  assert_output --partial "validate"
  assert_output --partial "+++ :rocket: push"
  assert_output --partial "push"
  assert_output --partial "apply"

  unstub atlas
}

@test "do it all on main, set env and config for apply" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="main"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_PLUGIN_ATLAS_STEP="all"
  export BUILDKITE_PLUGIN_APPLY_ENV="meow"
  export BUILDKITE_PLUGIN_ATLAS_CONFIG="file://theopenlane-atlas.hcl"
  export BUILDKITE_COMMIT="24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
  export CONTEXT=$(cat <<EOF
{
    "branch": "main",
    "commit": "24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
}
EOF
)

  stub atlas \
    'migrate lint --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR -w --format "{{ json .  }}" --context "$CONTEXT" : echo lint' \
    'migrate validate --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR : echo validate' \
    'migrate push $BUILDKITE_PLUGIN_ATLAS_PROJECT --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR --context "$CONTEXT" : echo push' \
    'migrate apply --env "meow" --config "file://theopenlane-atlas.hcl" : echo apply' \


  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "+++ :database: lint"
  assert_output --partial "lint"
  assert_output --partial "validate"
  assert_output --partial "+++ :rocket: push"
  assert_output --partial "push"
  assert_output --partial "apply"

  unstub atlas
}

@test "do it all, but its not main" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="meow"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"
  export BUILDKITE_PLUGIN_ATLAS_STEP="all"
  export BUILDKITE_COMMIT="24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
  export CONTEXT=$(cat <<EOF
{
    "branch": "meow",
    "commit": "24160da9f34e863b2d8fcc1fe6599d868e19f6b7"
}
EOF
)

  stub atlas \
    'migrate lint --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR -w --format "{{ json .  }}" --context "$CONTEXT" : echo lint' \
    'migrate validate --dev-url $BUILDKITE_PLUGIN_ATLAS_DEV_URL --dir $BUILDKITE_PLUGIN_ATLAS_DIR : echo validate' \


  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "+++ :database: lint"
  assert_output --partial "lint"
  assert_output --partial "validate"
  assert_output --partial "+++ :rocket: push"
  assert_output --partial "not pushing migration"

  unstub atlas
}

@test "missing project" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="meow"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial " BUILDKITE_PLUGIN_ATLAS_PROJECT: unbound variable"
}

@test "missing dir" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="meow"
  export BUILDKITE_PLUGIN_ATLAS_DEV_URL="sqlite://dev?mode=memory&_fk=1"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial " BUILDKITE_PLUGIN_ATLAS_DIR: unbound variable"
}

@test "missing url" {
  export BUILDKITE_PIPELINE_DEFAULT_BRANCH="main"
  export BUILDKITE_BRANCH="meow"
  export BUILDKITE_PLUGIN_ATLAS_DIR="file://db/migrations"
  export BUILDKITE_PLUGIN_ATLAS_PROJECT="meow"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial " BUILDKITE_PLUGIN_ATLAS_DEV_URL: unbound variable"
}



