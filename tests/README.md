# Terraform tests

## `./examples`

```shell
terraform init -test-directory=tests/examples
terraform test -test-directory=tests/examples
```

## `./local`

```shell
terraform init -test-directory=tests/local
terraform test -test-directory=tests/local
```

## `./remote`

```shell
terraform init -test-directory=tests/remote
terraform test -test-directory=tests/remote
```
