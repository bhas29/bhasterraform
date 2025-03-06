resource "aws_s3_bucket" "mybucket" {
bucket = "test-bucket"
acl = "public-read"   # 👈 This is a security risk (lint issue)
}

resource "aws_instance" "myinstance" {ami="ami-12345678" instance_type="t2.micro"}   # 👈 Bad formatting
