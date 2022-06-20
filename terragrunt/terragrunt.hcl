locals {
  dirs             = split("/", path_relative_to_include())
  org              = "abn-amro"
  product          = "Innovation"
  channel          = "Strategy"
  env              = local.dirs[0]
  stack            = "eks"
  aws_region       = "eu-west-1"
}


remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket = join("-", [
      lower(local.org),
      lower(local.channel),
      lower(local.product),
      lower(local.env),
      lower(local.aws_region),
      "tfstate",
    ])
    key    = "${local.env}-${local.stack}.tfstate"
    region = local.aws_region
    dynamodb_table = join("-", [
      lower(local.org),
      lower(local.channel),
      lower(local.product),
      "tflock",
      lower(local.env),
    ])
  }
}

inputs = merge(
  {
    org         = local.org
    product     = local.product
    channel     = local.channel
    environment = local.env
    stack       = local.stack
    aws_region  = local.aws_region
    
    remote_infra_bucket = join("-", [
      lower(local.org),
      lower(local.channel),
      lower(local.product),
      lower(local.env),
      lower(local.aws_region),
      "tfstate",
    ])
    remote_infra_key = "${local.env}-${local.stack}.tfstate"
  }
)
