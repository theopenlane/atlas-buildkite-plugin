[![Build status](https://badge.buildkite.com/cf752698f275643f5163411a872eefef64ff44e486f386a872.svg)](https://buildkite.com/theopenlane/atlas-buildkite-plugin)

# Atlas Buildkite Plugin

Buildkite plugin that will `lint`, `migrate` and `push` [atlas](https://atlasgo.io/cloud/) db schemas

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - plugins:
      - theopenlane/atlas#v1.1.0:
          dir: file://db/migrations
          project: theopenlane
          dev-url: sqlite://dev?mode=memory
          step: all
```

## Environment Variables

1. `ATLAS_CLOUD_TOKEN` is required to be set in the environment before the plugin can run
1. `TURSO_TOKEN` is required if you are applying your schema to a turso database

## Developing

To run the linter:
```shell
task lint
```

To run the tests:

```shell
task test
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request
