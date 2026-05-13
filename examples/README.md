## Example: Reboot Required Check

This example runs a shell script daily to check whether a reboot is required.

```hcl
module "run_ssm_document" {
  source = "git@github.com:wearetechnative/terraform-aws-module-ssm-command-document-runner.git"
  schedule = "cron(23 11 * * ? *)"
  document_name = "modulecheck"
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
  apply_only_at_cron_interval = true
}
```