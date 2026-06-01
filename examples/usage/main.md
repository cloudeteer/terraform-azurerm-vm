This example demonstrates the usage of the virtual machine module with default settings. It sets up all necessary dependencies, including a resource group, virtual network, subnet, recovery services vault, backup policy, and key vault, to ensure seamless deployment.

> [!TIP]
> Our module intentionally keeps password-based login available for Linux virtual machines through the `authentication_type` input variable. Where your security policy requires SSH-only access, set `authentication_type = "SSH"`. When you intentionally allow Linux password authentication and need to suppress the corresponding [Trivy](https://trivy.dev) warning, add the comment `#trivy:ignore:AVD-AZU-0039` directly above the Terraform module definition, as shown in the example below.
