terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "AQAAAAAS9j4ZAATuwaB6EWjQVE5PuHLDBOmXiaI"
  cloud_id  = "b1gm53rrhubfia3qpp2g"
  folder_id = "b1g6i02oni8ft6c24ped"
  zone      = "ru-central1-a"
}

               # Создание статического ключа доступа

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "ajec54kmcc4gi78eqhuh"
  description        = "static access key for object storage"
}

data "terraform_remote_state" "vpc" {
  backend = "?"

  config = {
    endpoint   = "storage.yandexcloud.net"
    region     = "ru-central1"
    access_key = "yandex_iam_service_account_static_access_key.sa-static-key.access_key"
    secret_key = "yandex_iam_service_account_static_access_key.sa-static-key.secret_key"
    bucket     = "diplom-netology-bucket"
    key        = "terraform.tfstate"
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
      image_id = "fd87va5cc00gaq2f5qfb"
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