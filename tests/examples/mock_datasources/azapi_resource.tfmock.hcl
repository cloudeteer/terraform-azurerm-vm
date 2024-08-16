mock_data "azapi_resource" {
  defaults = {
    output = jsonencode(
      {
        id       = "/Subscriptions/5f5b1043-3d3c-4047-8baf-1ebe8875da85/Providers/Microsoft.Compute/Locations/westeurope/Publishers/MicrosoftWindowsServer/ArtifactTypes/VMImage/Offers/WindowsServer/Skus/2022-datacenter-g2/Versions/20348.2582.240703"
        location = "westeurope"
        name     = "20348.2582.240703"
        properties = {
          architecture = "x64"
          automaticOSUpgradeProperties = {
            automaticOSUpgradeSupported = false
          }
          dataDiskImages = []
          disallowed = {
            vmDiskType = "Unmanaged"
          }
          features = [
            {
              name  = "SecurityType"
              value = "TrustedLaunchAndConfidentialVmSupported"
            },
            {
              name  = "IsAcceleratedNetworkSupported"
              value = "True"
            },
            {
              name  = "DiskControllerTypes"
              value = "SCSI, NVMe"
            },
            {
              name  = "IsHibernateSupported"
              value = "True"
            },
          ]
          hyperVGeneration = "V2"
          imageDeprecationStatus = {
            imageState = "Active"
          }
          osDiskImage = {
            operatingSystem = "Windows"
            sizeInGb        = 127
          }
          replicaCount = 10
          replicaType  = "Managed"
        }
      }
    )
  }
}
