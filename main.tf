resource "aws_ssm_document" "reboot_check" {
  name          = var.document_name
  document_type = "command"
  content = var.content
}

resource "aws_ssm_association" "run_reboot_doc" {
  name = aws_ssm_document.reboot_check.name

  targets {
    key    = "InstanceIds"
    values = var.targets
  }
  schedule_expression = var.schedule
  apply_only_at_cron_interval = var.apply_only_at_cron_interval
}

