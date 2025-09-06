data "aws_caller_identity" "current" {}

output "current_account" {
    value = data.aws_caller_identity.current.account_id
}