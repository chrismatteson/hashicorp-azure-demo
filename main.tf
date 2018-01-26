resource "azurerm_resource_group" "azure_vault_demo" {
  name     = "matteson_azure_vault_demo"
  location = "West US"
}

resource "azurerm_sql_server" "azure_sql_server" {
    name = "cmattesonsqlserver"
    resource_group_name = "${azurerm_resource_group.azure_vault_demo.name}"
    location = "West US"
    version = "12.0"
    administrator_login = "dbadmin"
    administrator_login_password = "Password1"
}

resource "azurerm_sql_database" "azure_sql_db" {
  name                = "llarsensqldatabase"
  resource_group_name = "${azurerm_resource_group.azure_vault_demo.name}"
  location = "West US"
  server_name = "${azurerm_sql_server.azure_sql_server.name}"

  tags {
    environment = "production"
  }
}

resource "azurerm_sql_firewall_rule" "allow_all" {
  name                = "Allow_All"
  resource_group_name = "${azurerm_resource_group.azure_vault_demo.name}"
  server_name         = "${azurerm_sql_server.azure_sql_server.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
