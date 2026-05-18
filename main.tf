data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_ssm_document" "ssm_doc" {
  name          = var.document_name
  document_type = "Command"
  content       = var.content
}

resource "aws_ssm_association" "run_ssm_doc" {
  name = aws_ssm_document.ssm_doc.name

  targets {
    key    = "InstanceIds"
    values = var.targets
  }
  schedule_expression         = var.schedule
  apply_only_at_cron_interval = var.apply_only_at_cron_interval
}

### This most likely will trigger events twice if the normal ssm rule is also enabled
## TODO: figure out solution for ths

resource "aws_cloudwatch_event_rule" "run_ssm_doc" {
  name        = "ssm document runner notification rule"
  description = "Capture each AWS Console Sign In"

  event_pattern = {
    "source" : ["aws.ssm"],
    "detail-type" : ["EC2 State Manager Instance Association State Change"],
    "detail" : {
      "status" : ["Failed"],
      "document-name" : [aws_ssm_document.ssm_doc.name]
    }
  }
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.run_ssm_doc.name
  target_id = "SendToObservability"
  arn       = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:observability-sns-topic"
}
