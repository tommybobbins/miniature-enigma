data "aws_iam_policy_document" "s3_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_replication" {
  count = data.aws_caller_identity.current.account_id == var.source_account ? 1 : 0
  name               = "s3-replication-configuration"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role.json
}

data "aws_iam_policy_document" "s3_replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [var.source_bucket_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectRetention",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectLegalHold",
    ]

    resources = [ "${var.source_bucket_arn}/*" ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ObjectOwnerOverrideToBucketOwner",  
      "s3:GetObjectVersionTagging",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = [ "${var.destination_bucket_arn}/*" ]
  }
}

resource "aws_iam_policy" "s3_replication" {
  count = data.aws_caller_identity.current.account_id == var.source_account ? 1 : 0
  name   = "s3-replication"
  policy = data.aws_iam_policy_document.s3_replication.json
}

resource "aws_iam_role_policy_attachment" "s3_replication" {
  count = data.aws_caller_identity.current.account_id == var.source_account ? 1 : 0
  role       = aws_iam_role.s3_replication[0].name
  policy_arn = aws_iam_policy.s3_replication[0].arn
}

resource "aws_s3_bucket_replication_configuration" "s3_replication" {
  count = data.aws_caller_identity.current.account_id == var.source_account ? 1 : 0
  role   = aws_iam_role.s3_replication[0].arn
  bucket        = split(":",var.source_bucket_arn)[5]

  rule {
    id = "allfiles"
    delete_marker_replication {
      status = "Enabled"
    }

    filter {}

    status = "Enabled"

    destination {
      bucket        = var.destination_bucket_arn
      storage_class = "STANDARD"
    }
  }
}


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
  count = data.aws_caller_identity.current.account_id == var.destination_account ? 1 : 0 
  bucket = split(":",var.destination_bucket_arn)[5]
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}