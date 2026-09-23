# terraform-aws-module-ssm-command-document-runner ![](https://img.shields.io/github/actions/workflow/status/wearetechnative/terraform-aws-module-ssm-command-document-runner/lint.yaml?branch=main&style=plastic&label=lint) ![](https://img.shields.io/github/actions/workflow/status/wearetechnative/terraform-aws-module-ssm-command-document-runner/security-scan.yaml?branch=main&style=plastic&label=security)
![](https://img.shields.io/github/license/wearetechnative/terraform-aws-module-ssm-command-document-runner?style=plastic)

<!-- SHIELDS -->

A reusable Terraform module to run AWS Systems Manager (SSM) documents on a schedule using SSM Associations.

This module creates:

- An AWS SSM Document
- An AWS SSM Association
- A configurable execution schedule using cron expressions
- Target selection for EC2 instances or managed nodes

It is designed for operational automation tasks such as:

- Reboot checks
- Patch validation
- Cleanup jobs
- Compliance checks
- Maintenance scripts
- Custom shell command execution

The module provides a simple and opinionated way to automate recurring SSM tasks across your AWS infrastructure.

[![](we-are-technative.png)](https://www.technative.nl)

---

# Features

- Create and manage SSM Documents with Terraform
- Run commands automatically on a schedule
- Support for cron-based execution
- Target one or multiple EC2 instances
- Optional delayed execution (`apply_only_at_cron_interval`)
- Lightweight and easy to integrate into existing infrastructure
- Fully compatible with Terraform AWS Provider

---

# How It Works

This module creates an AWS Systems Manager Association that periodically executes an SSM document against selected targets.

## Architecture

```text
Terraform
    │
    ├── aws_ssm_document
    │        │
    │        ▼
    │   SSM Command Document
    │
    └── aws_ssm_association
             │
             ▼
      Scheduled Execution
             │
             ▼
        SSM Managed Instances
```

The SSM Agent running on the target EC2 instances retrieves and executes the document according to the configured schedule.

---

# Requirements

Before using this module, ensure the following requirements are met.

## EC2 Requirements

Target instances must:

- Have the SSM Agent installed and running
- Be registered as SSM Managed Instances
- Have an IAM role attached with at least:

```text
AmazonSSMManagedInstanceCore
```

## Networking Requirements

Instances require outbound access to:

- `ssm`
- `ssmmessages`
- `ec2messages`

Either through:

- Internet/NAT Gateway
- Or VPC Interface Endpoints

---

# Usage

## Refer to the Example in example section

# Scheduling

AWS SSM Associations use CloudWatch Event style cron expressions.

Example schedules:

| Description | Expression |
|---|---|
| Every day at 02:00 UTC | `cron(0 2 * * ? *)` |
| Every hour | `cron(0 * * * ? *)` |
| Every Monday at 06:00 UTC | `cron(0 6 ? * MON *)` |

More information:
https://docs.aws.amazon.com/systems-manager/latest/userguide/reference-cron-and-rate-expressions.html

---

# Module Behaviour

## apply_only_at_cron_interval

When enabled:

```hcl
apply_only_at_cron_interval = true
```

The association will:

- NOT execute immediately after creation
- ONLY execute during the next scheduled interval

This is useful when:

- Avoiding immediate production impact
- Coordinating maintenance windows
- Preventing unwanted execution during Terraform apply

## EventBridge failure notifications

When enabled:

```hcl
create_event_bridge_rule = true
```

The module creates an EventBridge rule that listens for failed SSM command invocation status changes for this document and sends matching events to the `observability-sns-topic` SNS topic in the current AWS account and region.

Use this when the default or central SSM notification rule is disabled and this document runner still needs failure alerts. Be aware that enabling this alongside an existing SSM failure notification rule may result in duplicate alerts.

---

# Targeting Instances

The module supports targeting:

- Specific EC2 instance IDs
- Managed instances
- Groups of instances

Example:

```hcl
targets = [
  "i-0123456789abcdef0",
  "i-0fedcba9876543210"
]
```

---

# Best Practices

## Recommended Usage

- Keep SSM documents small and focused
- Prefer idempotent shell scripts
- Use cron schedules conservatively
- Test documents manually before scheduling
- Use tagging strategies for scalable targeting

## Security Recommendations

- Use least-privilege IAM policies
- Restrict document permissions where possible
- Audit command execution using CloudTrail
- Prefer VPC Endpoints over public internet access

---

# Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.run_ssm_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_ssm_association.run_ssm_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association) | resource |
| [aws_ssm_document.ssm_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_only_at_cron_interval"></a> [apply\_only\_at\_cron\_interval](#input\_apply\_only\_at\_cron\_interval) | Disable this option if you do not want an association to run immediately after you create or update it. | `bool` | `true` | no |
| <a name="input_content"></a> [content](#input\_content) | script we need to run on the ssm managed ssm instances | `string` | n/a | yes |
| <a name="input_create_event_bridge_rule"></a> [create\_event\_bridge\_rule](#input\_create\_event\_bridge\_rule) | Create a eventbridge rule specific for this doc runner, for when the normal ssm rule is disabled | `bool` | `false` | no |
| <a name="input_document_name"></a> [document\_name](#input\_document\_name) | The name you want to give to your ssm document and please make sure that it is descriptive as it will be used in the alerts | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The timezone of cron expression is UTC | `string` | `"cron(0 10 ? * * *)"` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | list of instance ids to be checked | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

---

# Development

## Formatting

```bash
terraform fmt -recursive
```

## Validate

```bash
terraform validate
```

## Linting

```bash
tflint
```

## Generate Terraform Docs

```bash
terraform-docs .
```

---

# Publishing

Once the module is production-ready:

1. Create a GitHub Release
2. Push semantic version tags
3. Publish to the Terraform Registry under the TechNative namespace

---

# Contributing

Contributions, issues, and feature requests are welcome.

Please ensure:

- Code is formatted
- Documentation is updated
- Pre-commit checks pass
- Terraform examples are validated

---

# License

MIT Licensed.

Copyright © TechNative B.V.
