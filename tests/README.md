# Terraform Tests

This directory contains a set of Terraform tests categorized into `local`, `remote`, and `examples` to streamline the development and CI/CD processes.

## `./examples`

This directory contains tests for all Terraform examples in `../examples`. Use the following commands to initialize and run the tests:

```shell
terraform init -test-directory=tests/examples
terraform test -test-directory=tests/examples
```

## `./local`

This directory is for tests intended to run locally during development. Use the following commands to initialize and run the tests:

```shell
terraform init -test-directory=tests/local
terraform test -test-directory=tests/local
```

## `./remote`

This directory contains tests designed to be executed by CI/CD pipelines. Use the following commands to initialize and run the tests:

```shell
terraform init -test-directory=tests/remote
terraform test -test-directory=tests/remote
```
