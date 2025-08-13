variable "name" {
  description = "Base name for alert resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Log Analytics workspace"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "action_group_id" {
  description = "ID of the action group for alert notifications"
  type        = string
}

resource "azurerm_monitor_scheduled_query_rules_log" "pod_crashloop" {
  name                = "${var.name}-pod-crashloop"
  location            = var.location
  resource_group_name = var.resource_group_name

  data_source_id = var.log_analytics_workspace_id
  description    = "Pods in CrashLoopBackOff"
  enabled        = true
  time_window_minutes         = 10
  evaluation_frequency_minutes = 5
  query = <<KQL
KubePodInventory
| where ContainerStatus contains "CrashLoopBackOff"
| summarize cnt = count() by ClusterName, Namespace, PodName, bin(TimeGenerated, 5m)
KQL

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [var.action_group_id]
  }
}
