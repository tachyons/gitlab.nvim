# Testing

Testing is done through the [plenary.test_harness](https://github.com/nvim-lua/plenary.nvim/tree/master#plenarytest_harness).

This test harness bundles the busted and luassert libraries into a Neovim
plugin which can be used to unit and integration test the GitLab plugin for
Neovim.

## Unit Tests

Unit tests can use Plenary's bundled version of Luassert to mock, stub, and spy
on objects.

Functions which interact with external services should be mocked with API calls
being stubbed appropriately.

```shell
# Run only specs defined under spec/gitlab/commands directory.
make test SPEC=spec/gitlab/commands

# Do not skip integration tests.
make test RUN_INTEGRATION_TESTS=true
```

## Integration Tests

To run integration tests run.

```shell
# Alias for test with RUN_INTEGRATION_TESTS set
make integration_test

# Run integration tests under the spec/integration directory.
make integration_test SPEC=spec/integration/categories/code_suggestions

# Run a specific integration spec file.
make integration_test SPEC=spec/integration/categories/code_suggestions/telemetry_spec.lua
```

### Running services locally

#### GitLab

Today functional tests assume you'll export `GITLAB_TOKEN` variable with the appropriate scopes to connect to GitLab.com.

#### Snowplow Micro

Inside of our GitLab CI/CD pipeline [Snowplow Micro](https://github.com/snowplow-incubator/snowplow-micro#snowplow-micro) is ran as a service container to verify telemetry.

If you'd like to test telemetry locally you can run Snowplow Micro before [running with integration tests enabled](#integration-tests).

You can run Snowplow Micro [inside of your GitLab Development Kit](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/howto/snowplow_micro.md).

##### Snowplow without GDK

<details><!-- {{{ -->
<summary>To run Snowplow Micro without the /GDK installed you <b>must</b> configure snowplow-micro to allow schemas from the GitLab Iglu registry.</summary>

To run the Snowplow Micro container in the foreground:

```shell
docker run --name snowplow-micro --rm -e MICRO_IGLU_REGISTRY_URL="https://gitlab-org.gitlab.io/iglu" -p 127.0.0.1:9091:9090 snowplow/snowplow-micro:latest
```

Or in the background:

```shell
docker run --name snowplow-micro -d -e MICRO_IGLU_REGISTRY_URL="https://gitlab-org.gitlab.io/iglu" -p 127.0.0.1:9091:9090 snowplow/snowplow-micro:latest
```

Confirm the service is running successfully:

```shell
curl -v "http://127.0.0.1:9091/micro/good" | jq .
docker logs -f snowplow-micro
```

Export `SNOWPLOW_MICRO_URL` if binding to non-standard location:

```shell
export SNOWPLOW_MICRO_URL='http://127.0.0.1:9091'
```

</details><!-- }}} -->
