
resource "yandex_vpc_network" "ansible_net" {
  name = "ansible-network"
}

resource "yandex_vpc_subnet" "ansible_subnet" {
  name           = "ansible-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.ansible_net.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}
data "yandex_compute_image" "almalinux" {
  family = "almalinux-9"
}

resource "yandex_compute_instance" "vms" {
  for_each    = toset(["clickhouse", "vector", "lighthouse"])
  name        = each.key
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  scheduling_policy {
    preemptible = true 
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = each.key == "clickhouse" ? data.yandex_compute_image.almalinux.image_id : data.yandex_compute_image.ubuntu.image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ansible_subnet.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    user-data          = templatefile("${path.module}/meta.tftpl", {
      key_terra   = trimspace(file("~/.ssh/id_ed25519.pub"))
      key_ansible = trimspace(file("ansible.pub"))
    })
  }
}
output "vm_ips" {
  value = {
    for k, v in yandex_compute_instance.vms : k => v.network_interface.0.nat_ip_address
  }
}
