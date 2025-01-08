# Sub-modules

Create directories for each sub-module as needed. The `README.md` files for each sub-module will be automatically generated using [terraform-docs](https://terraform-docs.io/user-guide/configuration/recursive/), just like the `README.md` of the primary module. Documentation generation requires a usage example in `./<module>/examples/usage/`, with a `main.tf` file defining the example and a `main.md` file briefly describing it.

Thus, the minimal file structure of a module is:

```tree
.
├── README.md
├── examples
│   └── usage
│       ├── main.md
│       └── main.tf
├── inputs.tf
├── main.tf
├── outputs.tf
└── terraform.tf
```
