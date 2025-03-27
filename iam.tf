# 1) IAM policy document for ec2-instance-connect
data "aws_iam_policy_document" "ec2_connect_custom" {
  statement {
    effect = "Allow"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey",
      "ec2-instance-connect:SendSerialConsoleSSHPublicKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_connect_custom" {
  name        = "EC2InstanceConnectCustom"
  policy      = data.aws_iam_policy_document.ec2_connect_custom.json
  description = "Custom policy for EC2 Instance Connect"
}



resource "aws_iam_role" "ec2_instance_connect_role" {
  name               = "EC2InstanceConnectRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_connect_assume_role.json

  tags = {
    Name = "EC2InstanceConnectRole"
  }
}

data "aws_iam_policy_document" "ec2_instance_connect_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}


resource "aws_iam_instance_profile" "ec2_connect_instance_profile" {
  name = "EC2ConnectInstanceProfile"
  role = aws_iam_role.ec2_instance_connect_role.name
}
