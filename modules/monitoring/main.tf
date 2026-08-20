# ============================================================
# Monitoring Module
# ============================================================
# Provides both platform-metric alerting and guest telemetry:
#   VM -> Azure Monitor Agent -> Data Collection Rule -> Log Analytics
# Azure platform CPU metrics are also evaluated by a metric alert.

# Central workspace for Windows event and performance data.
resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Install Azure Monitor Agent inside the Windows guest.
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true

  tags = var.tags
}

# Data Collection Rule defines which guest data is collected and where
# Collect selected Windows events and performance counters.
resource "azurerm_monitor_data_collection_rule" "this" {
  name                = "dcr-${var.name_prefix}-windows"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "log-analytics"
    }
  }

  data_flow {
    streams      = ["Microsoft-Event", "Microsoft-Perf"]
    destinations = ["log-analytics"]
  }

  data_sources {
    # Collect warning/error/critical events from common Windows logs.
    windows_event_log {
      name    = "windows-events"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }

    # Guest counters supplement Azure platform metrics with OS-level data.
    performance_counter {
      name                          = "windows-performance"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes"
      ]
    }
  }
}

# Associate the DCR with this VM so Azure Monitor knows the target from
# which the configured event logs and performance counters are collected.
resource "azurerm_monitor_data_collection_rule_association" "vm" {
  name                    = "dcra-${var.name_prefix}-windows"
  target_resource_id      = var.virtual_machine_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id

  # Ensure the guest agent exists before the collection association is
  # applied. The DCR itself already depends on Log Analytics implicitly.
  depends_on = [azurerm_virtual_machine_extension.azure_monitor_agent]
}

# Action Group is the reusable destination for Azure Monitor alerts.
# No email/webhook receiver is configured by default to keep the sample
# environment deployable without requiring personal contact information.
resource "azurerm_monitor_action_group" "this" {
  name                = "ag-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  short_name          = "tflab"
  tags                = var.tags
}

# Platform metric alert: Azure evaluates Percentage CPU without relying
# on the guest agent or Log Analytics ingestion path.
resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "alert-${var.name_prefix}-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.virtual_machine_id]
  description         = "Alert when average VM CPU exceeds 80 percent for the evaluation window."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}
