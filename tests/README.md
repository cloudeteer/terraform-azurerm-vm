# Terraform tests

## `./examples`

```shell
for file in ./examples/*/*.tf; do
  sed -i.backup 's|source *= *"cloudeteer/vm/azurerm"|source = "../.."|g' $file
done

terraform init -test-directory=tests/examples
terraform test -test-directory=tests/examples

for file in ./examples/*/*.tf.backup; do
  mv $file ${file%.backup}
done
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
