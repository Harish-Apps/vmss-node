variable "regions" {
  description = "Configuration for hub and spoke networks per region"
  type = map(object({
    hub = object({
      address_space = list(string)
      subnets       = map(string)
    })
    spokes = map(object({
      address_space = list(string)
      subnets       = map(string)
    }))
  }))
  default = {
    eastus = {
      hub = {
        address_space = ["10.0.0.0/16"]
        subnets = {
          GatewaySubnet      = "10.0.0.0/24"
          AzureFirewallSubnet = "10.0.1.0/24"
          LoadBalancerSubnet  = "10.0.2.0/24"
        }
      }
      spokes = {
        dev = {
          address_space = ["10.1.0.0/16"]
          subnets = {
            app  = "10.1.1.0/24"
            db   = "10.1.2.0/24"
            mgmt = "10.1.3.0/24"
          }
        }
        test = {
          address_space = ["10.2.0.0/16"]
          subnets = {
            app  = "10.2.1.0/24"
            db   = "10.2.2.0/24"
            mgmt = "10.2.3.0/24"
          }
        }
        prod = {
          address_space = ["10.3.0.0/16"]
          subnets = {
            app  = "10.3.1.0/24"
            db   = "10.3.2.0/24"
            mgmt = "10.3.3.0/24"
          }
        }
      }
    }
    westeurope = {
      hub = {
        address_space = ["10.10.0.0/16"]
        subnets = {
          GatewaySubnet      = "10.10.0.0/24"
          AzureFirewallSubnet = "10.10.1.0/24"
          LoadBalancerSubnet  = "10.10.2.0/24"
        }
      }
      spokes = {
        dev = {
          address_space = ["10.11.0.0/16"]
          subnets = {
            app  = "10.11.1.0/24"
            db   = "10.11.2.0/24"
            mgmt = "10.11.3.0/24"
          }
        }
        test = {
          address_space = ["10.12.0.0/16"]
          subnets = {
            app  = "10.12.1.0/24"
            db   = "10.12.2.0/24"
            mgmt = "10.12.3.0/24"
          }
        }
        prod = {
          address_space = ["10.13.0.0/16"]
          subnets = {
            app  = "10.13.1.0/24"
            db   = "10.13.2.0/24"
            mgmt = "10.13.3.0/24"
          }
        }
      }
    }
  }
}
