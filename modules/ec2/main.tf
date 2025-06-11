module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name          = var.ec2_instance.name
  subnet_id     = var.ec2_instance.subnet_id
  instance_type = var.ec2_instance.instance_type
  ami           = var.ec2_instance.ami
  vpc_security_group_ids = var.ec2_instance.vpc_security_group_ids

  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
