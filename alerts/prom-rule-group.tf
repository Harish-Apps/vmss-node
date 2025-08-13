variable "name" {
  description = "Base name for alert resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Azure Monitor workspace"
  type        = string
}

variable "monitor_workspace_id" {
  description = "ID of the Azure Monitor workspace"
  type        = string
}

variable "action_group_id" {
  description = "ID of the action group for alert notifications"
  type        = string
}

resource "azurerm_monitor_alert_prometheus_rule_group" "app_slo" {
  name                = "${var.name}-prom-slo"
  location            = var.location
  resource_group_name = var.resource_group_name
  scopes              = [var.monitor_workspace_id]
  interval            = "PT1M"
  enabled             = true

  rule {
    alert  = "High5xxRate"
    expr   = "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) > 0.005"
    for    = "PT5M"
    labels = {
      severity = "2"
      team     = "platform"
    }
    annotations = {
      summary     = "5xx error rate > 0.5% for 5m"
      description = "Check recent deployments or upstream dependencies."
    }
    action {
      action_group_id = var.action_group_id
    }
  }

  rule {
    alert = "LatencyP95High"
    expr  = "histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m]))) > 0.3"
    for   = "PT10M"
    labels = { severity = "2" }
    annotations = { summary = "p95 > 300ms" }
  }
}
