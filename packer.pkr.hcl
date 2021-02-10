variable "create_ami_name" {
  type    = string
}

variable "original_ami_name" {
  type    = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_id" {
  type    = string
}

// The below creates a filename friendly timestamp
// for a unique AMI 
locals { timestamp = regex_replace(timestamp(), "[ :]", "") }

source "amazon-ebs" "ami_build" {
  ami_name      = "${var.create_ami_name} ${local.timestamp}"
  // ami_users     = ["123123123"]
  instance_type = "t2.large"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = "20"
  }
  region             = var.region
  // security_group_ids = "${var.security_groups}"
  source_ami_filter {
    filters = {
      name = "${var.original_ami_name}*"
    }
    most_recent = true
    owners      = ["self"]
  }
  ssh_username = "centos"
  // subnet_id    = "${var.subnet_id}"
  vpc_id       = "${var.vpc_id}"
}


build {
  sources = ["source.amazon-ebs.ami_build"]

  provisioner "file" {
    destination = "~/_packer_tmp.sh"
    source      = "./root_build.sh"
  }
  provisioner "shell" {
    inline = ["sudo bash ~/_packer_tmp.sh"]
  }
  provisioner "file" {
    destination = "~/_packer_tmp_u.sh"
    source      = "./user_build.sh"
  }
  provisioner "shell" {
    inline = ["bash ~/_packer_tmp_u.sh", "rm ~/_packer_tmp*"]
  }
  provisioner "inspec" {
    inspec_env_vars = [ "CHEF_LICENSE=accept"]
    profile = "./inspec/"
  }
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
