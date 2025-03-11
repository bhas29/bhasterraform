#testing with complete and half yml
#testing full

resource "aws_iam_policy" "bad_policy" {
  name        = "badPolicy"
  description = "Policy with too broad permissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}
