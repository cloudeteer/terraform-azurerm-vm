# Example: Domain Join

This example demonstrates how to automatically join a virtual machine to an Active Directory Domain using the `JsonADDomainExtension` provided by the `Microsoft.Compute` publisher.

The process involves setting the `domain_join` and `domain_join_password` variables. In this example, the domain join username and password are securely retrieved from Azure Key Vault to enable automatic domain joining.

Follow this example to streamline the integration of your virtual machines with Active Directory domains.
