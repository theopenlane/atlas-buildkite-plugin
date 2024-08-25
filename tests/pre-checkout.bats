#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
# export WHICH_STUB_DEBUG=/dev/tty

@test "log in to atlas when installed" {
  export ATLAS_CLOUD_TOKEN="testtoken"

  stub which 'atlas : echo /usr/bin/atlas'
  stub which 'jq : echo /usr/bin/jq'

  stub atlas \
    'login --token $ATLAS_CLOUD_TOKEN : echo You are now connected to meow on Atlas Cloud'

  run "$PWD/hooks/pre-checkout"

  assert_success
  assert_output --partial "/usr/bin/atlas"
  assert_output --partial "/usr/bin/jq"
  assert_output --partial "connected"

  unstub which
  unstub atlas
}
