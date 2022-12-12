terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

               # Centos 7 image

data "yandex_compute_image" "centos7" {
  family = "centos-7"
}

provider "yandex" {
  token     = "AQAAAAAS9j4ZAATuwaB6EWjQVE5PuHLDBOmXiaI"
  cloud_id  = "b1gm53rrhubfia3qpp2g"
  folder_id = "b1g6i02oni8ft6c24ped"
  zone      = "ru-central1-b"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    endpoint   = "storage.yandexcloud.net"
    region     = "ru-central1"
    access_key = "YCAJEdWj_znXM1jI2-oQzyKpE"
    secret_key = "YCPAo9koLP51oMQ-Ll3Z11KuSxFRkE6iwFxDuTP3"
    bucket     = "diplom-netology-bucket"
    key        = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

resource "yandex_compute_instance" "vm-4" {
  name = "terraform4"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos7.id
    }
  }

  network_interface {
    subnet_id = data.terraform_remote_state.vpc.outputs.node_sub
    nat       = true
  }

  metadata   = {
    user-data = "${file("/home/evgen/repo/diplom-terraform/metadata.yml")}"
    serial-port-enable = 1
  }
}