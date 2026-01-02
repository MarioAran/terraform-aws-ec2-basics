terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

data "aws_vpc" "default" {
    default = true
  
}



