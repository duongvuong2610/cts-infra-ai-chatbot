variable "ec2_instance" {
  type = object({
    name = string
    subnet_id = string
    instance_type = string
    ami = string
    vpc_security_group_ids = list(string)
  })
}