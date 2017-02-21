variable "region" {}

provider "aws" {
  region      = "${var.region}"
  max_retries = "10"
}

module "main" {
  source           = "../tf"
  region           = "${var.region}"
}
