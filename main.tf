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
  count       = var.create_event_bridge_rule == true ? 1 : 0
  name        = "${var.document_name}-rule"
  description = "Capture failed association document runs"

  event_pattern = jsonencode({
    "source" : ["aws.ssm"],
    "detail-type" : ["EC2 Command Invocation Status-change Notification"],
    "detail" : {
      "status" : ["Failed"],
      "document-name" : [aws_ssm_document.ssm_doc.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  count     = var.create_event_bridge_rule == true ? 1 : 0
  rule      = aws_cloudwatch_event_rule.run_ssm_doc[0].name
  target_id = "SendToObservability"
  arn       = "arn:aws:sns:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:observability-sns-topic"
}
