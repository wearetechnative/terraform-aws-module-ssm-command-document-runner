# VARIABLES
variable "schedule" {
  type = string
  default = "cron(0 10 ? * * *)"
}

variable "apply_only_at_cron_interval" {
  type = bool
  default = true
	description = "Enable this option if you do not want an association to run immediately after you create or update it. "
}

variable "targets" {
	type = list(string)
	default = [ "*" ]
	description = "list of instance ids to be checked"
}