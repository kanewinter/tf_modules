variable "log_bucket" {}

variable "tags" {
  type = "map"
}

variable "priceclass" {
  default = "PriceClass_100"
}

variable "cert" {}