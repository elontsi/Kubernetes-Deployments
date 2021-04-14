variable "Region" {
  default = "eu-west-2"
}

variable "AMI" {
    type     = map
    default  = {
        eu-west-2 = "ami-02701bcdc5509e57b"
    }
}