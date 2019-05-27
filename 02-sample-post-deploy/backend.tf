terraform {
  backend "azurerm" {
    key = "sample-post-deploy.tfstate"
  }
}
