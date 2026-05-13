resource "aws_ssm_document" "ssm_doc" {
  name          = var.document_name
  document_type = "Command"
  content = var.content
}

resource "aws_ssm_association" "run_ssm_doc" {
  name = aws_ssm_document.ssm_doc.name

  targets {
    key    = "InstanceIds"
    values = var.targets
  }
  schedule_expression = var.schedule
  apply_only_at_cron_interval = var.apply_only_at_cron_interval
}

