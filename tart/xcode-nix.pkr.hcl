packer {
  required_plugins {
    tart = {
      version = ">= 1.2.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "macos_version" {
  type = string
}

variable "xcode_version" {
  type = string
}

source "tart-cli" "tart" {
  vm_base_name = "${var.macos_version}-xcode:${var.xcode_version}"
  vm_name      = "${var.macos_version}-xcode-nix-config:${var.xcode_version}"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 100
  headless     = true
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
}

build {
  sources = ["source.tart-cli.tart"]

  // Install xcode-select tools
  provisioner "shell" {
    inline = [
      "touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;",
      "PROD=$(softwareupdate -l | grep \"\\*.*Command Line\" | tail -n 1 | sed 's/^[^C]* //')",
      "softwareupdate -i \"$PROD\" --verbose;",
    ]
  }

  // Install Nix
  provisioner "shell" {
    inline = [
      "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --extra-conf 'trusted-users = admin' --no-confirm",
    ]
  }

  // Create the nix folder
  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/nix",   // Create the directory if it doesn't exist
    ]
  }

  provisioner "file" {
    source      = "nix/"
    destination = "/tmp/nix"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp/nix",
      "nix develop .#mobile --impure --accept-flake-config"
    ]
  }
}
