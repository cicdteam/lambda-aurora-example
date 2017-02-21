resource "aws_iam_role" "demo" {
    name = "iam_for_lambda_demo"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# This policy need to run Lambda in VPC
#
resource "aws_iam_role_policy" "demo" {
    name = "lambda-demo"
    role = "${aws_iam_role.demo.id}"
    policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"AllowCreationOfLogGroupsAndStreams",
            "Effect":"Allow",
             "Action":[
                "logs:CreateLogGroup",
                "logs:CreateLogStream"
             ],
            "Resource":"arn:aws:logs:*:*:*"
        },
        {
            "Sid":"AllowLogging",
            "Effect":"Allow",
            "Action":"logs:PutLogEvents",
            "Resource":"arn:aws:logs:*:*:log-group:/aws/lambda/*:*"
        },
        {
            "Sid":"AllowEniMgmtForVpcAccess",
            "Effect":"Allow",
            "Action":[
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource":"*"
        }
    ]
}
EOF
}





resource "aws_lambda_function" "demo" {
  depends_on = ["null_resource.demo", "aws_rds_cluster.demo", "aws_rds_cluster_instance.demo"]
  filename = "../lambda/lambda-demo.zip"
  function_name = "lambda-demo"
  runtime = "python2.7"
  timeout = 30
  role = "${aws_iam_role.demo.arn}"
  handler = "lambda-demo.handler"
  source_code_hash = "${base64sha256(file("../lambda/lambda-demo.zip"))}"
  vpc_config {
    subnet_ids         = ["${aws_subnet.demo.*.id}"]
    security_group_ids = ["${aws_security_group.demo.id}"]
  }
}
