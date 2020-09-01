terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket = "otus"
    key    = "terraform.tfstate"
    region = "us-east-1"
    prefix = "stage"
    skip_credentials_validation = true
  }
}
