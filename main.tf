provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.20.0"
  features {}
}

data "azurerm_client_config" "current" {}


resource "azurerm_api_management_product" "apiMgmtProductDemo" {
  product_id    = "apim-demo"
  display_name  = "APIM Demo"
  description   = "A demo Product"
  subscription_required = true
  approval_required = true
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  published = true
  subscriptions_limit = 2
  terms = "you better accept this or else... ;-)"
}




resource "azurerm_api_management_api_operation_policy" "testapi_getop_policy" {
  api_name            = azurerm_api_management_api_operation.testapi_getop.api_name
  api_management_name = azurerm_api_management_api_operation.testapi_getop.api_management_name
  resource_group_name = azurerm_api_management_api_operation.testapi_getop.resource_group_name
  operation_id        = azurerm_api_management_api_operation.testapi_getop.operation_id
  xml_content = <<XML
                <policies>
                  <inbound>
                    <mock-response status-code="200" content-type="application/json"/>
                  </inbound>
                </policies>
                XML
}


resource "azurerm_api_management_api_version_set" "demo-api-versionset" {
  count               = length(var.client_services)
  name                = var.version_set_name
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  display_name        = "demo-api-versionset"
  versioning_scheme   = "Segment"
}


resource "azurerm_api_management_api" "demo-api-v1" {
  count               = length(var.client_services)
  name                = "${var.version_set_name}-v1"
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  revision            = "1"
  display_name        = "${var.apim-api-display-name}-v1"
  path                = "v1"
  protocols           = ["https"]
  service_url         = "https://${var.apim-api-display-name}/v1/dpo"
  version             = "v1"
  version_set_id      = azurerm_api_management_api_version_set.demo-api-versionset[count.index].id
  import {
    content_format = "swagger-json"
    content_value  = file("${path.module}/colors.json")
  }
}


resource "azurerm_api_management_api" "client-api-v2" {
  count               = length(var.client_services)
  name                = "${var.version_set_name}-v2"
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  revision            = "1"
  display_name        = "${var.apim-api-display-name}-v2"
  path                = "v2"
  protocols           = ["https"]
  service_url         = "https://${var.apim-api-display-name}/v2/dpo"
  version             = "v2"
  version_set_id      = azurerm_api_management_api_version_set.demo-api-versionset[count.index].id
   import {
    content_format = "swagger-json"
    content_value  = file("${path.module}/colors.json")
  }
}