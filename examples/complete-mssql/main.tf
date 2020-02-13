provider "aws" {
  region = "ap-southeast-2"
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

#####
# DB
#####
module "db" {
  source = "../../"

  identifier = "dr-demodb"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_encrypted = false

  name     = null # "dr-demodb"
  username = "demouser"
  password = "YourPwdShouldBeLongAndSecure!"
  port     = "1433"

  vpc_security_group_ids = [data.aws_security_group.default.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "david wright"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "dr-demodb"

  create_db_parameter_group = false
  license_model             = "general-public-license"

  timezone = "AUS Eastern Standard Time"

  # Database Deletion Protection
  deletion_protection = false

  # DB options
  major_engine_version = "5.7"

  options = []
}
