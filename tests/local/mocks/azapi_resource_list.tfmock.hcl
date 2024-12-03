mock_data "azapi_resource_list" {
  defaults = {
    output = [
      {
        id       = "/Subscriptions/00000000-0000-0000-0000-000000000000/Providers/Microsoft.Compute/Locations/MOCK_LOCATION/Publishers/MOCK_PUBLISHER/ArtifactTypes/MOCK_TYPE/Skus/MOCK_SKU/Versions/0.0.1",
        location = "MOCK_LOCATION",
        name     = "0.0.1"
      }
    ]
  }
}
