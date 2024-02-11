provider "azurerm" {
  features {}
<<<<<<< HEAD
  tenant_id       = "735c2154-9cf0-4178-a7a8-00f406920e99"
  subscription_id = "23a55b34-95b8-42f4-a8cd-d4c734d74f2e"  
}

resource "azurerm_resource_group" "example" {
  name     = "Genai-RG"
=======

}

resource "azurerm_resource_group" "example" {
  name     = "Demo_RG"
>>>>>>> origin/main
  location = "East US"
}
