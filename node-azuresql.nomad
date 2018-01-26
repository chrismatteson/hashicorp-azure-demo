job "node" {
  datacenters = ["dc1"]
  type = "service"
  group "node" {
    count = 1
    task "node" {
      driver = "docker"
      config {
        image = "lanceplarsen/node-azuresql:latest"
        volumes = ["local/config.js:/usr/src/app/config.js"]
        network_mode = "host"
        port_map {
          app = 3000
        }
      }

      template {
        data = <<EOH
        module.exports = {
          "azuresql_db": "{{ key "azuresql/database" }}",
          "azuresql_server": "{{ key "azuresql/server" }}",
          "vault_url": "http://vault.service.consul:8200"
        };
        EOH

        destination = "local/config.js"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "app" {
            static = 3000
          }
        }
      }

      service {
        name = "nodejs"
        port = "app"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      vault {
        policies = ["azuresql"]
        change_mode   = "restart"
      }

    }
  }
}
