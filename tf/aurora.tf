resource "aws_db_subnet_group" "demo" {
    name = "lambda-demo"
    subnet_ids = ["${aws_subnet.demo.*.id}"]
    tags {
        Name = "DB subnet group for lambda-demo"
    }
}

resource "aws_rds_cluster" "demo" {
  cluster_identifier      = "lambda-demo"
  database_name           = "lambdademo"
  master_username         = "${var.db_username}"
  master_password         = "${var.db_password}"
  db_subnet_group_name    = "${aws_db_subnet_group.demo.id}"
  vpc_security_group_ids  = ["${aws_security_group.demo.id}"]
}

resource "aws_rds_cluster_instance" "demo" {
  count                   = 2
  identifier              = "lambda-demo-${count.index}"
  cluster_identifier      = "${aws_rds_cluster.demo.id}"
  instance_class          = "db.t2.medium"
  db_subnet_group_name    = "${aws_db_subnet_group.demo.id}"
}


# Create rds_config.py file and zip all lambda python files to archive
#
resource "null_resource" "demo" {
  triggers {
    aurora  = "${aws_rds_cluster.demo.endpoint}"
    db_user = "${var.db_username}"
    db_pass = "${var.db_password}"
    code    = "${file("${path.module}/../lambda/lambda-demo.py")}"
  }

  provisioner "local-exec" {
    command = <<EOF
 (cd ../lambda/;
 echo '#!/usr/bin/python' >rds_config.py;
 echo '#config file containing credentials for rds aurora instance' >>rds_config.py;
 echo 'db_username = "${var.db_username}"' >>rds_config.py;
 echo 'db_password = "${var.db_password}"' >>rds_config.py;
 echo 'db_name = "lambdademo"' >>rds_config.py;
 echo 'db_endpoint = "${aws_rds_cluster.demo.endpoint}"' >>rds_config.py;
 chmod 755 lambda-demo.py rds_config.py;
 zip -q -r lambda-demo.zip pymysql lambda-demo.py rds_config.py)
EOF
  }
}
