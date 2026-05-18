variable "schedule" {
  type        = string
  default     = "cron(0 10 ? * * *)"
  description = "The timezone of cron expression is UTC"
}

variable "apply_only_at_cron_interval" {
  type        = bool
  default     = true
  description = "Disable this option if you do not want an association to run immediately after you create or update it. "
}

variable "targets" {
  type        = list(string)
  default     = ["*"]
  description = "list of instance ids to be checked"
}

variable "content" {
  type        = string
  description = "script we need to run on the ssm managed ssm instances"
}


variable "document_name" {
  type        = string
  description = "The name you want to give to your ssm document and please make sure that it is descriptive as it will be used in the alerts"
}
