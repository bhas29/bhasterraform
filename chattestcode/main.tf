resource "aws_instance" "example" {
  count = var.instance_count
  ####ami           = "ami-12345678" # Example AMI ID (use a valid one)
  instance_type = var.instance_type

  tags = {
    Name        = "ExampleInstance"
    Environment = "Testing" # Improperly formatted tag (fmt warning)
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "echo Hello from Terraform"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-${random_id.bucket_id.hex}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "ExampleBucket"
    Environment = "Production"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}
