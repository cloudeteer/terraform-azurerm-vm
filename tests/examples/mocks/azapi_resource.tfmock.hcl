mock_data "azapi_resource" {
  defaults = {
    output = {
      id       = "/Subscriptions/00000000-0000-0000-0000-000000000000/Providers/Microsoft.Compute/Locations/MOCK_LOCATION/Publishers/MOCK_PUBLISHER/ArtifactTypes/MOCK_TYPE/Skus/MOCK_SKU/Versions/0.0.1",
      location = "MOCK_LOCATION",
      name     = "0.0.1",
      properties = {
        architecture                 = "x64",
        automaticOSUpgradeProperties = { "automaticOSUpgradeSupported" : false },
        dataDiskImages               = [],
        disallowed                   = { "vmDiskType" : "Unmanaged" },
        features = [
          {
            name  = "SecurityType",
            value = "TrustedLaunchAndConfidentialVmSupported"
          },
          { name = "IsAcceleratedNetworkSupported", value = "True" },
          { name = "DiskControllerTypes", value = "SCSI, NVMe" },
          { name = "IsHibernateSupported", value = "True" }
        ],
        hyperVGeneration       = "V2",
        imageDeprecationStatus = { "imageState" : "Active" },
        osDiskImage            = { "operatingSystem" : "Windows", "sizeInGb" : 127 },
        replicaCount           = 10,
        replicaType            = "Managed"
      }
    }
  }
}
