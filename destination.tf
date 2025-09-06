data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.source_account}:role/s3-replication-configuration"]
    }

    actions = [
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [
      var.destination_bucket_arn,
      "${var.destination_bucket_arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count  = data.aws_caller_identity.current.account_id == var.destination_account ? 1 : 0
  bucket = split(":", var.destination_bucket_arn)[5]
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}