variable "service" {}

variable "environment" {}

variable "tags" {
  type = "map"
}

variable "redrive_policy" { default="" }
variable "fifo_queue" { default="false" }
variable "visibility_timeout_seconds" {default=30 }