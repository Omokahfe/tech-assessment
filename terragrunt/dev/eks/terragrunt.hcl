include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../terraform//eks"
}

inputs = {
  aws_region = "eu-west-1"

  cluster_name     = "abn-amro"
  cluster_version  = "1.21"
  eks_ami_id       = "ami-06a0cc2bb4748fc42"

  instance_type        = "t2.micro"
  asg_desired_capacity = 2
  asg_min_size         = 2
  asg_max_size         = 3

}
