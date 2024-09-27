provider "aws" {
  alias = "region1"
  region     = var.region1
  profile    = "terraform"
}
provider "aws" {
  alias = "region2"
  region     = var.region2
  profile    = "terraform"
}

