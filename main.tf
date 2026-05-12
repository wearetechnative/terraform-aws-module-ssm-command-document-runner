resource "aws_ssm_document" "reboot_check" {
  name          = "VerifyRebootRequired"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Command Document to verify reboot required on instance",
    "mainSteps": [
        {
            "action": "aws:runShellScript",
            "name": "VerifyRebootRequired",
            "inputs": {
                "runCommand": [
                "file=/var/run/reboot-required",
                "if [ -f \"$file\" ]; then",
                " echo 'reboot required file exist'",
                " exit 1",
                "else",
                " echo 'reboot not required'",
                " exit 0",
                "fi"
                ]
            }
        }
    ]
  }
  DOC
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

