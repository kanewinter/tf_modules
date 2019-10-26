variable "tags" {
  type = "map"
}

variable "domain" {
  description = "Domain to use for SES"
}

variable "sender" {
  default = "mail"
}

variable "zone_id" {
  description = "Route 53 zone ID for the SES domain verification"
}

variable "ses_records" {
  description = "Additional entries which are added to the _amazonses record"
  default = []
}